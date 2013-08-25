require 'spec_helper'

describe User do
  let(:subject) { User.new }
  
  it {should have_many(:projects).dependent(:nullify) }
  
  it "should be able to create new project" do
    expect { subject.create_project(project_params) }.to change(Project, :count).by(1)
  end
  
private
  def project_params
    {name: "Test", path_to_rails_root: Rails.root.to_s }
  end
end
