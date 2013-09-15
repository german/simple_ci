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
    
    project_dir = File.join BuildRunner.tmp_dir_for(subject), File.basename(subject.project.path_to_rails_root)
    expect( Dir.entries project_dir ).to include('spec')
  end
end