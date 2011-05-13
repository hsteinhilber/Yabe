require 'faker' unless Rails::env == "production"

namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    owner = Author.create!(:name => "Harry Steinhilber, Jr.",
                           :email => "harry.steinhilber@gmail.com",
                           :password => "secret",
                           :password_confirmation => "secret")
    owner.toggle!(:owner)
    next if Rails::env == "production"

    Author.create!(:name => "Primary Author",
                   :email => "first.author@example.com",
                   :password => "foobar",
                   :password_confirmation => "foobar")
    98.times do |n|
      name = Faker::Name.name
      email = "author-#{n+1}@example.org"
      password = "pa55w0rd"
      Author.create!(:name => name,
                     :email => email,
                     :password => password,
                     :password_confirmation => password)
    end
  end
end

