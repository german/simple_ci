require "bunny"

class Build < ActiveRecord::Base
  include AASM
  
  belongs_to :project
  
  aasm do
    state :created, :initial => true
    state :enqueued
    state :running
    state :deploying
    state :failure
    state :success
  
    event :enqueue, :after => :enqueue_task do      
      transitions :from => [:created, :failure, :success], :to => :enqueued
    end
    
    event :run do
      transitions :from => :enqueued, :to => :running
    end
    
    event :succeed do      
      transitions :from => [:running, :deploying], :to => :success
    end
    
    event :fail do      
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
