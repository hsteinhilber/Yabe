Factory.define :author do |author|
  author.name                  "Test Author"
  author.email                 "test.author@example.com"
  author.password              "secret"
  author.password_confirmation "secret"
end

Factory.sequence :email do |n|
  "test-email-#{n+1}@example.com"
end
