# == Schema Information
# Schema version: 20110606111155
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
#  cached_slug  :string(255)
#  month        :integer
#  year         :integer
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

  default_scope where('published_on <= :published', :published => 1.minute.from_now).order('published_on DESC')
  before_save :on_before_save

  def tag_tokens=(ids)
    ids.gsub!(/\[(.+?)\]/) { Tag.create!(:name => $1).id } 
    self.tag_ids = ids.split(',')
  end

  private 
    def on_before_save
      self.published_on ||= Time.now
      self.month = self.published_on.month
      self.year = self.published_on.year
    end

end
