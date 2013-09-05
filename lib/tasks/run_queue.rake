require "bunny"

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
      puts " [#{DEFAULT_QUEUE}] Received #{params.inspect}"
      BuildRunner.run params[:build_id]
            
      ch.ack(delivery_info.delivery_tag)
    end
  rescue Interrupt => _
    conn.close
  end
end
