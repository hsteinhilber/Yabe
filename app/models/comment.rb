class Comment < ActiveRecord::Base
  attr_accessible :name, :url, :email, :body
  belongs_to :post

  default_scope :order => "created_at ASC"
end
