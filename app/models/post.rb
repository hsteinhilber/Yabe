# == Schema Information
# Schema version: 20110530135930
#
# Table name: posts
#
#  id           :integer         not null, primary key
#  title        :string(75)
#  body         :text
#  created_at   :datetime
#  updated_at   :datetime
#  author_id    :integer
#  published_on :datetime
#

class Post < ActiveRecord::Base
  attr_accessible :title, :body, :published_on, :tag_tokens
  attr_reader :tag_tokens
  belongs_to :author
  has_many :comments, :dependent => :destroy
  has_and_belongs_to_many :tags, :uniq => true
  has_friendly_id :title, :use_slug => true

  validates :title, :presence => true,
                    :length => { :maximum => 75 }
  validates :body, :presence => true

  default_scope :order => 'published_on DESC'
  before_save :set_published_on

  def tag_tokens=(ids)
    ids.gsub!(/\[(.+)\]/) { Tag.create!(:name => $1).id } 
    self.tag_ids = ids.split(',')
  end

  private 
    def set_published_on
      self.published_on ||= Time.now
    end

end
