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
  
  it "have initial state :created" do
    subject.created?.should == true
  end
  
  it "is runnable" do
    subject.run!
    subject.running?.should == true
  end
  
  it "is creates build when runned" do
    lambda { subject.run! }.should change(Build, :count).by(1)
  end
  
  it "is creates build when runned" do
    subject.run!
    Build.last.running?.should == true
  end
end
