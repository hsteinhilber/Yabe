require 'spec_helper'

describe Author do
  before(:each) do
    @attr = { :name => "Basic Author", 
              :email => "author@example.com",
              :password => "secret", 
              :password_confirmation => "secret" }
  end

  it "should create a new instance given valid attributes" do
    Author.create!(@attr)
  end

  describe "name validation" do 
    it "should require a name" do
      no_name = Author.new(@attr.merge(:name => ""))
      no_name.should_not be_valid
    end

    it "should reject names that are too long" do
      long_name = Author.new(@attr.merge(:name => "a" * 51))
      long_name.should_not be_valid
    end
  end
 
  describe "email validation" do
    it "should require an email" do
      no_email = Author.new(@attr.merge(:email => ""))
      no_email.should_not be_valid
    end

    it "should reject duplicate email addresses" do
      Author.create!(@attr)
      duplicate_email = Author.new(@attr)
      duplicate_email.should_not be_valid
    end

    it "should reject duplicate email addresses regardless of case" do
      Author.create!(@attr.merge(:email => @attr[:email].upcase))
      duplicate_email = Author.new(@attr)
      duplicate_email.should_not be_valid
    end

    it "should accept valid email addresses" do
      addresses = %w[author@example.com SIMPLE_USER@foo.bar.com first.last@mycompany.us]
      addresses.each do |address|
        valid_email = Author.new(@attr.merge(:email => address))
        valid_email.should be_valid
      end
    end

    it "should reject invalid email addresses" do
      addresses = %w[author@example author_example.com something@example]
      addresses.each do |address|
        invalid_email = Author.new(@attr.merge(:email => address))
        puts invalid_email.email unless !invalid_email.valid?
        invalid_email.should_not be_valid
      end
    end
  end

  describe "password validation" do
    it "should require a password" do
      no_password = Author.new(@attr.merge(:password => "",
                                         :password_confirmation => ""))
      no_password.should_not be_valid
    end

    it "should require a matching password confirmation" do
      mismatch_confirmation = Author.new(@attr.merge(:password_confirmation => "invalid"))
      mismatch_confirmation.should_not be_valid
    end

    it "should reject passwords that are too short" do
      short = "a" * 5
      short_password = Author.new(@attr.merge(:password => short,
                                            :password_confirmation => short))
      short_password.should_not be_valid
    end

    it "should reject passwords that are too long" do
      long = "a" * 21
      long_password = Author.new(@attr.merge(:password => long,
                                           :password_confirmation => long))
      long_password.should_not be_valid
    end
  end

  describe "password encryption" do
    before(:each) do
      @author = Author.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @author.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @author.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do
      it "should be true if the passwords match" do
        @author.has_password?(@attr[:password]).should be_true
      end

      it "should be false if the passwords don't match" do
        @author.has_password?("invalid").should be_false
      end
    end

    describe "authenticate method" do
      it "should return nil on email/password mismatch" do
        wrong_password = Author.authenticate(@attr[:email], "invalid")
        wrong_password.should be_nil
      end

      it "should return nil for a non-existant email address" do
        nonexistant = Author.authenticate("foo@bar.com", @attr[:password])
        nonexistant.should be_nil
      end

      it "should return the author on email/password match" do
        matching = Author.authenticate(@attr[:email], @attr[:password])
        matching.should == @author
      end
    end
  end
end
