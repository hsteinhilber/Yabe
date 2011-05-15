Factory.define :author do |author|
  author.name                  "Test Author"
  author.email                 "test.author@example.com"
  author.password              "secret"
  author.password_confirmation "secret"
end

Factory.define :post do |post|
  post.title "My Amazing Post!"
  post.body  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras tempus interdum enim, ultricies aliquam odio elementum eu."
end

Factory.sequence :email do |n|
  "test-email-#{n+1}@example.com"
end
