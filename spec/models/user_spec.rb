require 'spec_helper'

describe User do
  let(:subject) { User.new }
  let(:project) { FactoryGirl.build(:project) }
  
  it {should have_many(:projects).dependent(:nullify) }
  
  it "should be able to create new project" do
    expect { subject.create_project(project.attributes) }.to change(Project, :count).by(1)
  end
end
