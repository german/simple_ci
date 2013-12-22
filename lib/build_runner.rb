require 'benchmark'
require 'fileutils'
require 'rvm'

class BuildRunner
  class << self
    
    def run(id)
      build = Build.find id
      
      prepare_tmp_dir_for build

      cd_project_dir(build) if build.project.copy_before_builds

      do_in_branch build.project.branch do
        copy_files_for build
      end if build.project.copy_before_builds

      output = ""
      build.run! # transition from :enqueued state to :running

      duration = Benchmark.measure do
        # TODO find_rspec
        # TODO run bundle install
        run_commands = []
        run_commands << "cd #{build_in_folder(build)}"
        run_commands << "bundle install" if build.project.run_bundle_before_builds
        run_commands << "bundle exec rspec"
        
        RVM.use_from_path! build.project.path_to_rails_root do
          output = `#{run_commands.join(' && ')}`
        end
      end
      puts " [#{DEFAULT_QUEUE}] Done: #{output}" if !Rails.env.test?

      quick_output = output.lines.try(:first).to_s.strip # ..F..*F*
      
      build.update_attributes output: output, failed_tests: quick_output.count('F'), pending_tests: quick_output.count('*'), succeeded_tests: quick_output.count('.'), duration: duration.to_s.match(/\((?<real_time>[\d\. ]+)\)/)[:real_time].to_f

      if quick_output.count('F') > 0
        build.fail!
      else
        build.succeed!
      end
      clear_files_after(build)
    rescue => e
      build.fail!
      clear_files_after(build)
      build.update_attributes output: (e.message + "\n\n" + e.backtrace.to_s)
    end
    
    def cd_project_dir(build)
      `cd #{build.project.path_to_rails_root}`
    end
    
    def do_in_branch(branch_name)
      git_branch_output = `git branch`
      original_branch = git_branch_output.split(/$/).detect{|b| b[0] == '*'}.match(/\w+/)[0]
      `git checkout #{branch_name}`
      yield
      `git checkout #{original_branch}`
    end
    
    def prepare_tmp_dir_for(build)
      log "preparing temp directory for the build #{build.id}"
      FileUtils.mkdir_p build.tmp_dir
    end
  
    def copy_files_for(build)
      log "copying files for the build #{build.id} from #{build.project.path_to_rails_root} into #{build.tmp_dir}"
      FileUtils.cp_r build.project.path_to_rails_root, build.tmp_dir
    end
  
    def clear_files_after(build)
      log "clearing files after build #{build.id}"
      FileUtils.rm_rf build.tmp_dir
    end
    
    def build_in_folder(build)
      build.project.copy_before_builds ? build.tmp_dir_with_project_name : build.project.path_to_rails_root
    end

    def log text
      puts text if Rails.env.development?
    end
  end
end
