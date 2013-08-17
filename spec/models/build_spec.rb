require 'spec_helper'

describe Build do
  subject { FactoryGirl.create :build }
  
  it {should belong_to(:project)}

  it "succeeds and the related project also should have success status" do
    subject.project.created?.should be
    subject.stubs(:enqueue_task).returns(true)    
    subject.run!
    subject.running?.should be
    subject.project.running?.should be
  end
end