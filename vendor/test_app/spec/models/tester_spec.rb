require 'spec_helper'

describe Tester do
  subject { Tester.new }

  it "has full name" do
    subject.first_name = "John"
    subject.last_name = "Doe"
    expect(subject.full_name).to eq("John Doe")
  end
end
