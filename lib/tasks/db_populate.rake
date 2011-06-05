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

    # Additional authors
    Author.create!(:name => "Primary Author",
                   :email => "first.author@example.com",
                   :password => "foobar",
                   :password_confirmation => "foobar")
    12.times do |n|
      name = Faker::Name.name
      email = Faker::Internet.email(name)
      password = '???#???#'.gsub(/\?/) { ('a'..'z').to_a.rand }.gsub(/#/) { rand(10).to_s } 
      Author.create!(:name => name,
                     :email => email,
                     :password => password,
                     :password_confirmation => password)
    end

    Author.all.each do |author|
      # Write post
      5.times do |n|
        title = Faker::Lorem.sentence(4).slice(0,75)
        body = Faker::Lorem.paragraphs(3)
        post = author.posts.create!(:author => author,
                                    :title => title,
                                    :body => body)      
        post.created_at = Time.now - rand(60 * 60 * 24 * 90)
        post.published_on = post.created_at + rand(60 * 60 * 24 * 5)
        post.save!
      end
    end

    # Create tags
    tags = Faker::Lorem.words(30).map { |s| Tag.find_or_create_by_name(s) }.uniq

    Post.all.each do |post|
      # Tag post
      (rand(4) + 1).times do
        post.tags << tags[rand(tags.length)]
      end

      # Comment on post
      rand(16).times do |n|
        commenter = Faker::Name.name
        email = Faker::Internet.email(commenter)
        url = case rand(10)
              when 0...2
                "http://#{Faker::Internet.domain_name}/#{Faker::Internet.user_name(commenter)}"
              when 2...5
                "http://#{Faker::Internet.user_name(commenter)}.#{Faker::Internet.domain_name}"                                                       
              else
                ""
              end
        body = Faker::Lorem.sentences(2)
        comment = post.comments.create!(:name => commenter,
                                             :email => email,
                                             :url => url,
                                             :body => body)
        comment.created_at = post.created_at - rand(60 * 60 * 24 * 5)
        comment.save!
      end
    end
  end
end

