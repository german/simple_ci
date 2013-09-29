# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = if User.count == 0
  if u = User.create!(email: 'simple_ci@example.com', password: 'password')
    puts "User with email 'simple_ci@example.com' and with password 'password' was created. Use it to log in into the SimpleCI."
    u
  end
else
  User.first
end

if Project.count == 0
  if Project.create!(name: 'Simple CI', path_to_rails_root: Rails.root.join('vendor','test_app').to_s, user: user)
    puts "Project 'Simple CI' was created."
  end
end
