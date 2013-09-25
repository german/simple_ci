require 'benchmark'
require 'fileutils'

class BuildRunner
  class << self
    
    def run(id)
      build = Build.find id
      
      self.prepare_tmp_dir_for(build)
      self.copy_files_for(build)
    
      output = ""
      build.run! # transition from :enqueued state to :running
    
      duration = Benchmark.measure do
        puts 'build.tmp_dir_with_project_name - ' + build.tmp_dir_with_project_name.inspect
        # TODO find_rspec
        # TODO run bundle install
        output = `cd #{build.tmp_dir_with_project_name} && rspec #{build.tmp_dir_with_project_name}/spec`
      end
      puts " [#{DEFAULT_QUEUE}] Done: #{output}" if !Rails.env.test?
    
      quick_output = output.lines.first.strip # ..F..*F*
      build.update_attributes output: output, failed_tests: quick_output.count('F'), pending_tests: quick_output.count('*'), succeeded_tests: quick_output.count('.'), duration: duration.to_s.match(/\((?<real_time>[\d\. ]+)\)/)[:real_time].to_f
    
      if quick_output.count('F') > 0
        build.fail!
      else
        build.succeed!
      end
    rescue => e
      build.fail!
      clear_files_after(build)
      build.update_attributes output: (e.message + "\n\n" + e.backtrace.to_s)
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