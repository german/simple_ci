require 'benchmark'
require 'fileutils'

class BuildRunner
  class << self
    
    def run(id)
      build = Build.find id
      
      self.prepare_tmp_dir_for(build)
      
      self.cd_project_dir(build)
      
      self.do_in_branch(build.project.branch) do
        self.copy_files_for(build)
      end

      output = ""
      build.run! # transition from :enqueued state to :running
    
      duration = Benchmark.measure do
        # TODO find_rspec
        # TODO run bundle install
        output = `cd #{build.tmp_dir_with_project_name} && rspec #{build.tmp_dir_with_project_name}/spec`
      end
      puts " [#{DEFAULT_QUEUE}] Done: #{output}" if !Rails.env.test?
    
      quick_output = output.lines.first.strip # ..F..*F*
      
      build.output = output
      build.failed_tests = quick_output.count('F')
      build.pending_tests = quick_output.count('*')
      build.succeeded_tests = quick_output.count('.')
      build.duration = duration.to_s.match(/\((?<real_time>[\d\. ]+)\)/)[:real_time].to_f
      build.save

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
      original_branch = `git branch`.split(/$/).detect{|b| b[0] == '*'}.match(/\w+/)[0]
      `git checkout #{branch_name}`
      yield
      `git checkout #{original_branch}`
    end
    
    def prepare_tmp_dir_for(build)
      puts "preparing temp directory for the build #{build.id}" if Rails.env.development?
      FileUtils.mkdir_p build.tmp_dir
    end
  
    def copy_files_for(build)
      puts "copying files for the build #{build.id} from #{build.project.path_to_rails_root} into #{build.tmp_dir}" if Rails.env.development?
      FileUtils.cp_r build.project.path_to_rails_root, build.tmp_dir
    end
  
    def clear_files_after(build)
      puts "clearing files after build #{build.id}" if Rails.env.development?
      FileUtils.rm_rf build.tmp_dir
    end
  end
end