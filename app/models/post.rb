# == Schema Information
# Schema version: 20110526131138
#
# Table name: posts
#
#  id         :integer         not null, primary key
#  title      :string(75)
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#  author_id  :integer
#

class Post < ActiveRecord::Base
  attr_accessible :title, :body
  belongs_to :author
  has_many :comments, :dependent => :destroy

  validates :title, :presence => true,
                    :length => { :maximum => 75 }
  validates :body, :presence => true

  default_scope :order => 'created_at DESC'
end
