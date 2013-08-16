class Project < ActiveRecord::Base
  include AASM
  
  belongs_to :user
  has_many :builds
  
  aasm do
    state :created, :initial => true
    state :running

    state :failure
    state :success
  
    event :run do
      after do
        self.builds.create!.run!
      end
      
      transitions :from => [:created, :failure, :success], :to => :running
    end
    
    event :fail do
      transitions :from => [:running], :to => :failure
    end
      
    event :succeed do
      transitions :from => [:running], :to => :success
    end
  end
end
