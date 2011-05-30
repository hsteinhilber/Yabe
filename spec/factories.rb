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

Factory.define :comment do |comment|
  comment.name  "Example Commenter"
  comment.email "commenter@example.com"
  comment.url   "http://example.com/commenter"
  comment.body  "Lorem ipsum dolor sit amet."
end

Factory.sequence :email do |n|
  "test-email-#{n+1}@example.com"
end

Factory.sequence :tag do |n|
  Tag.create!(:name => "Tag #{n}")
end
