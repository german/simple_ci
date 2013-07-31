class Project < ActiveRecord::Base
  include AASM
  
  belongs_to :user
  
  aasm do
    state :created, :initial => true
    state :running
    state :deploying
    state :failure
    state :success
  end
end
