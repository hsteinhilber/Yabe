# == Schema Information
# Schema version: 20110530181624
#
# Table name: tags
#
#  id   :integer         not null, primary key
#  name :string(35)
#

class Tag < ActiveRecord::Base
  has_and_belongs_to_many :posts
  validates :name, :presence => true,
                   :uniqueness => { :case_sensitive => false }

  class ::String 
    def to_tag
      Tag.find_or_create_by_name(self)
    end
  end
end
