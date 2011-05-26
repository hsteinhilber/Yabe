# == Schema Information
# Schema version: 20110104233042
#
# Table name: authors
#
#  id                 :integer         not null, primary key
#  name               :string(75)
#  email              :string(75)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(64)
#  salt               :string(64)
#  profile            :text
#  owner              :boolean
#

require 'digest'

class Author < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation
  has_many :posts, :dependent => :destroy

  validates :name, :presence => true,
                   :length => { :maximum => 50 }
  validates :email, :presence => true,
                    :format => /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
                    :uniqueness => { :case_sensitive => false }
  validates :password, :presence => true,
                       :confirmation => true,
                       :length => { :within => 6..20 }
  before_save :encrypt_password

  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def self.authenticate(email, submitted_password)
    author = find_by_email(email)
    return nil if author.nil?
    return author if author.has_password?(submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    author = find_by_id(id)
    (author && author.salt == cookie_salt) ? author : nil
  end

  private
    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
    end

    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
