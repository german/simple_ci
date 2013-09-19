require 'spec_helper'

describe Build do
  subject { FactoryGirl.create :build }
  
  after do
    BuildRunner.clear_files_after(subject)
  end
  
  it {should belong_to(:project)}
  
  it "copies project to temp directory" do
    expect {
      BuildRunner.run subject.id
    }.to change{ Dir.entries(Dir.tmpdir)}
    
    expect( Dir.entries subject.tmp_dir_with_project_name ).to include('spec')
  end
end