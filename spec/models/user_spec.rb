require 'spec_helper'

describe User do
  before(:each) do
    @attr = { :name => "Basic User", :email => "user@example.com" }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "should require a name" do
    no_name = User.new(@attr.merge(:name => ""))
    no_name.should_not be_valid
  end

  it "should require an email" do
    no_email = User.new(@attr.merge(:email => ""))
    no_email.should_not be_valid
  end

  it "should reject names that are too long" do
    long_name = User.new(@attr.merge(:name => "a" * 51))
    long_name.should_not be_valid
  end

  it "should reject duplicate email addresses" do
    User.create!(@attr)
    duplicate_email = User.new(@attr)
    duplicate_email.should_not be_valid
  end

  it "should reject duplicate email addresses regardless of case" do
    User.create!(@attr.merge(:email => @attr[:email].upcase))
    duplicate_email = User.new(@attr)
    duplicate_email.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@example.com SIMPLE_USER@foo.bar.com first.last@mycompany.us]
    addresses.each do |address|
      valid_email = User.new(@attr.merge(:email => address))
      valid_email.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@example user_example.com something@example]
    addresses.each do |address|
      invalid_email = User.new(@attr.merge(:email => address))
      puts invalid_email.email unless !invalid_email.valid?
      invalid_email.should_not be_valid
    end
  end
end
