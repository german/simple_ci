class Project < ActiveRecord::Base
  include AASM
  
  belongs_to :user
  has_many :builds
  
  aasm do
    state :created, :initial => true
    state :enqueued
    state :running
    state :failure
    state :success
  
    event :enqueue do
      after do
        self.builds.create!.enqueue!
      end
      
      transitions :from => [:created, :failure, :success], :to => :enqueued
    end
    
    event :run do
      transitions :from => :enqueued, :to => :running
    end
    
    event :fail do
      transitions :from => :running, :to => :failure
    end
      
    event :succeed do
      transitions :from => :running, :to => :success
    end
  end
end
