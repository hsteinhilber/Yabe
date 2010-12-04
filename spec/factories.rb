Factory.define :user do |user|
  user.name                  "Test User"
  user.email                 "test.user@example.com"
  user.password              "secret"
  user.password_confirmation "secret"
end
