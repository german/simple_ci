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
        output = `rspec #{tmp_dir_for(build)}/spec`
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
      build.update_attributes output: (e.message + "\n\n" + e.backtrace.to_s)
    end

    def prepare_tmp_dir_for(build)
      puts "preparing temp directory for the build #{build.id}" if Rails.env.development?
      FileUtils.mkdir_p tmp_dir_for(build)
    end
  
    def copy_files_for(build)
      puts "copying files for the build #{build.id} from #{build.project.path_to_rails_root} into #{tmp_dir_for(build)}" if Rails.env.development?
      FileUtils.cp_r(build.project.path_to_rails_root, tmp_dir_for(build))
    end
  
    def clear_files_after(build)
      puts "clearing files after build #{build.id}" if Rails.env.development?
      FileUtils.rm_rf(tmp_dir_for(build))
    end
  
    def tmp_dir_for(build)
      File.join tmp_dir, "project#{build.project.id}"
    end
  
    def tmp_dir
      Dir.tmpdir
    end
  end
end