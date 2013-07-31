FactoryGirl.define do
  factory :project do
    name 'Simple CI'
    path_to_rails_root Rails.root.to_s
  end
end