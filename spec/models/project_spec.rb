require 'spec_helper'

describe Project do
  subject { FactoryGirl.create :project }
  
  it "have unique name and path on filesystem"
  
  it "have full qualified path" do
    subject.path_to_rails_root.should =~ /\/simple_ci/
  end
  
  it "have rspec/cucumber/test::unit option selected"
  
  it "have initial state :created" do
    subject.created?.should == true
  end
  
  it "is runnable" do
    subject.run!
    subject.running?.should == true
  end
  
  it "is been added to the queue for the performance" do
    lambda {
      subject.run!
    }.should change(TasksQueue.count).by(1)
  end
  
  it "returns line with spec status" do
    subject.run!
    subject.status = "..F..*F*"
    subject.failed?.should == true
  end
end
