# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if User.count == 0
  if User.create!(email: 'simple_ci@example.com', password: 'password')
    puts "User with email 'simple_ci@example.com' and with password 'password' was created. Use it to log in into the SimpleCI."
  end
end