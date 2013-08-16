require 'spec_helper'

describe Build do
  subject { FactoryGirl.create :build }
  
  it {should belong_to(:project)}

  it "saves spec status" do
    subject.run!
    subject.status = "..F..*F*"
    subject.failed?.should == true
  end
end