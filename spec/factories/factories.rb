FactoryGirl.define do
  factory :project do
    name 'Simple CI'
    path_to_rails_root Rails.root.join('vendor', 'test_app').to_s
  end
  
  factory :build do
    output '*....F...F...'
    failed_tests 2
    pending_tests 1
    succeeded_tests 10
    duration 0.456
    project
  end
  
  factory :user do
    email 'simple_ci@example.com'
    password '12345678'
  end
end