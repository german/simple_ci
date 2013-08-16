require "bunny"

class Build < ActiveRecord::Base
  include AASM
  
  belongs_to :project
  
  aasm do
    state :created, :initial => true
    state :running
    state :deploying
    state :failure
    state :success
  
    event :run, :after => :enqueue_task do
      transitions :from => [:created, :failure, :success], :to => :running
    end
    
    event :succeed do
      after do
        self.project.succeed!
      end
      
      transitions :from => [:running, :deploying], :to => :success
    end
    
    event :fail do
      after do
        self.project.fail!
      end
      
      transitions :from => [:running, :deploying], :to => :failure
    end
    
    event :deploy do
      transitions :from => [:success], :to => :deploying
    end
  end
    
  def enqueue_task
    conn = Bunny.new
    conn.start

    ch   = conn.create_channel
    q    = ch.queue(DEFAULT_QUEUE, :durable => true)
    msg  = Marshal.dump build_id: self.id

    q.publish(msg, :persistent => true)
    Rails.logger.warn " [#{DEFAULT_QUEUE}] Sent #{msg}"

    conn.close
  end
end
