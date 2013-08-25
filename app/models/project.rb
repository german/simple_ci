class Project < ActiveRecord::Base
  include AASM
  
  belongs_to :user
  has_many :builds
  
  validates :name, :path_to_rails_root, presence: true
  validates :path_to_rails_root, rails_project: true
  
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
      transitions :from => [:enqueued, :running], :to => :failure
    end
      
    event :succeed do
      transitions :from => :running, :to => :success
    end
  end
end
