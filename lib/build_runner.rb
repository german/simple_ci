require 'benchmark'

class BuildRunner
  def self.run(id)
    build = Build.find id
          
    output = ""
    build.run! # transition from :enqueued state to :running
    duration = Benchmark.measure do
      output = `rspec #{build.project.path_to_rails_root}/spec`
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
end