require 'spec_helper'

describe Project do
  subject { FactoryGirl.create :project }
  
  before do
    Build.any_instance.stubs(:enqueue_task).returns(true)
  end

  it {should have_many(:builds)}
  
  it "have unique name and path on filesystem"
  
  it "have full qualified path" do
    subject.path_to_rails_root.should =~ /\/simple_ci/
  end
  
  it "have rspec/cucumber/test::unit option selected"
  
  context "initial state" do
    it "have initial state :created" do
      subject.created?.should == true
    end
  end
  
  context "enqueued state" do  
    it "is creates build when enqueued" do
      lambda { subject.enqueue! }.should change(Build, :count).by(1)
    end
  
    it "is creates build with status enqueued" do
      subject.enqueue!
      subject.builds.last.enqueued?.should be
    end
  end
 
  context "runned state" do
    before do
      subject.enqueue!
    end
    
    it "is runnable" do
      subject.run!
      subject.running?.should be
    end
    
    it "has build that switches project to the running state (from different worker process)" do
      subject.builds.last.run!
      subject.reload
      subject.running?.should be
    end
  end
end