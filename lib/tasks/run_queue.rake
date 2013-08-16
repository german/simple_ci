require "bunny"
require 'benchmark'

desc "Run all tasks from the queue"
task :run_queue => :environment do
  conn = Bunny.new
  conn.start

  ch   = conn.create_channel
  q    = ch.queue(DEFAULT_QUEUE, :durable => true)

  ch.prefetch(1)
  puts " [*] Waiting for messages. To exit press CTRL+C"

  begin
    q.subscribe(:ack => true, :block => true) do |delivery_info, properties, body|
      params = Marshal.load(body)
      build = Build.find params[:build_id]
      
      puts " [#{DEFAULT_QUEUE}] Received #{params.inspect}"
      output = ""
      duration = Benchmark.measure do
        output = `rspec #{build.project.path_to_rails_root}/spec`
      end
      puts " [#{DEFAULT_QUEUE}] Done: #{output}"
      
      quick_output = output.lines.first.strip # ..F..*F*
      build.update_attributes output: output, failed_tests: quick_output.count('F'), pending_tests: quick_output.count('*'), succeeded_tests: quick_output.count('.'), duration: duration.to_s.match(/\((?<real_time>[\d\. ]+)\)/)[:real_time].to_f
      
      if quick_output.count('F') > 0
        build.fail!
      else
        build.succeed!
      end
      
      ch.ack(delivery_info.delivery_tag)
    end
  rescue Interrupt => _
    conn.close
  end
end
