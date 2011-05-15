# == Schema Information
# Schema version: 20110515143014
#
# Table name: posts
#
#  id         :integer         not null, primary key
#  title      :string(35)
#  body       :text
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
