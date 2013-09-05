require 'spec_helper'

describe Project do
  subject { FactoryGirl.create :project }
  
  before do
    Build.any_instance.stubs(:enqueue_task).returns(true)
  end

  it {should belong_to(:user)}
  it {should have_many(:builds)}
  
  it "have unique name and path on filesystem"
  
  it "have full qualified path" do
    subject.path_to_rails_root.should =~ /\/simple_ci/
  end
  
  it "have rspec/cucumber/test::unit option selected"
  
  context "create new build" do  
    it "is creates build with status enqueued" do
      lambda {
        subject.builds.create!.enqueue!
      }.should change(Build, :count).by(1)
      subject.builds.last.enqueued?.should be
    end
  end
end