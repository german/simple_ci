require "bunny"

class Build < ActiveRecord::Base
  attr_accessible :output, :duration, :failed_tests, :pending_tests, :succeeded_tests
  
  include AASM
  
  belongs_to :project
  
  # we should enqueue build only after it's fully changed its state (e.g. will have aasm_state attribute set to 'enqueued')
  # so worker script could find it and invoke `run!` properly (otherwise transision errors)
  after_commit :enqueue_task, on: :update, if: lambda {|build| build.enqueued? }
    
  aasm do
    state :created, :initial => true
    state :enqueued
    state :running
    state :deploying
    state :failure
    state :success
  
    event :enqueue do      
      transitions :from => [:created, :failure, :success], :to => :enqueued
    end
    
    event :run do
      transitions :from => :enqueued, :to => :running
    end
    
    event :succeed do      
      transitions :from => [:running, :deploying], :to => :success
    end
    
    event :fail do      
      transitions :from => [:enqueued, :created, :running, :deploying], :to => :failure
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
  
  def tmp_dir
    File.join TMP_DIR, "project_#{self.project.id}_#{self.project.branch}"
  end
  
  def tmp_dir_with_project_name
    File.join tmp_dir, File.basename(self.project.path_to_rails_root)
  end
end
