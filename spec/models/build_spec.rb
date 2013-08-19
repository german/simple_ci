require 'spec_helper'

describe Build do
  subject { FactoryGirl.create :build }
  
  it {should belong_to(:project)}
end