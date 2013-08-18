require 'spec_helper'

describe Build do
  subject { FactoryGirl.create :build }
  
  it {should belong_to(:project)}

  it "adds to the queue" do
    subject.created?.should be
    subject.stubs(:enqueue_task).returns(true)    
    subject.enqueue!
    subject.enqueued?.should be
  end
end