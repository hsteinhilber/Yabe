# == Schema Information
# Schema version: 20101201195101
#
# Table name: posts
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  body       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Post < ActiveRecord::Base
  attr_accessible :title, :body
  has_many :comments, :dependent => :destroy

  validates :title, :presence => true,
                    :length => { :maximum => 35 }
  validates :body, :presence => true
end
