class Comment < ActiveRecord::Base
  attr_accessible :name, :url, :email, :body
  belongs_to :post
end
