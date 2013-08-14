require "bunny"

class Project < ActiveRecord::Base
  include AASM
  
  belongs_to :user
  
  aasm do
    state :created, :initial => true
    state :running
    state :deploying
    state :failure
    state :tests_success
    state :deploy_success
    
    event :run do
      transitions :from => [:created, :failure, :tests_success, :deploy_success], :to => :running
    end
    
    event :deploy do
      transitions :from => [:tests_success], :to => :deploying
    end
  end
  
  def run
    conn = Bunny.new
    conn.start

    ch   = conn.create_channel
    q    = ch.queue(DEFAULT_QUEUE, :durable => true)
    msg  = Marshal.dump project_id: self.id

    q.publish(msg, :persistent => true)
    Rails.logger.warn " [#{DEFAULT_QUEUE}] Sent #{msg}"

    conn.close
  end
end
