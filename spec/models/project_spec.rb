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
end
