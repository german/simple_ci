require 'spec_helper'

describe Build do
  subject { FactoryGirl.create :build }
  
  after do
    BuildRunner.clear_files_after(subject)
  end
  
  it {should belong_to(:project)}
  
  it "copies project to temp directory and cleanes it up after the build" do
    subject.enqueue!
    
    expect {
      BuildRunner.run subject.id
    }.not_to change{ Dir.entries(TMP_DIR)}
  end
end