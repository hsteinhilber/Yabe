# == Schema Information
# Schema version: 20110515143014
#
# Table name: comments
#
#  id         :integer         not null, primary key
#  post_id    :integer
#  name       :string(75)
#  url        :string(150)
#  email      :string(75)
#  body       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Comment < ActiveRecord::Base
  attr_accessible :name, :url, :email, :body
  belongs_to :post

  default_scope :order => "created_at ASC"
  validates :post_id, :presence => true
  validates :name, :presence => true, :length => { :maximum => 75 }
  validates :email, :presence => true, :format => /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :url, :format => /\A((\s*)|(http(s?)\:\/\/[0-9a-z]([-.\w]*[0-9a-z])*(:(0-9)*)*(\/?)([a-z0-9\-\.\?\,\'\/\\\+&%\$#_=]*)))\z/i 
  validates :body, :presence => true, :length => { :maximum => 255 }
end
