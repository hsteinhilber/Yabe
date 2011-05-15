require 'spec_helper'

describe Comment do
  
  before(:each) do
    @post = Factory(:post)
    @attr = { 
      :name => "Commenter", 
      :email => "commenter@example.com", 
      :url => "http://example.com/commenter", 
      :body => "Lorem Ipsum Dolor" 
    }
  end

  it "should create a new Comment given valid attributes" do
    @post.comments.create!(@attr)
  end

  describe "association with post" do

    before(:each) do
      @comment = @post.comments.create(@attr)
    end

    it "should have a post attribute" do
      @comment.should respond_to(:post)
    end

    it "should be associated with the correct post" do
      @comment.post_id.should == @post.id
      @comment.post.should == @post
    end
  end

  describe "validation" do

    it "should require a post" do
      Comment.new(@attr).should_not be_valid
    end

    it "should require a name" do
      @post.comments.build(@attr.merge(:name => " ")).should_not be_valid
    end

    it "should not allow names to be too long" do
      long_name = "a" * 76
      @post.comments.build(@attr.merge(:name => long_name)).should_not be_valid
    end

    it "should require an email address" do
      @post.comments.build(@attr.merge(:email => "")).should_not be_valid
    end

    addresses = %w[commenter@example.com ALLCAP_COMMENTER@foo.bar.com basic.commenter@mycompany.us]
    addresses.each do |address|
      it "should accept valid email addresses like '#{address}'" do
        @post.comments.build(@attr.merge(:email => address)).should be_valid
      end
    end

    addresses = %w[commenter@example commenter_example.com something@com another@blah.]
    addresses.each do |address|
      it "should reject invalid email addresses like '#{address}'" do
        @post.comments.build(@attr.merge(:email => address)).should_not be_valid
      end
    end

    it "should allow a blank url" do
      @post.comments.build(@attr.merge(:url => "  ")).should be_valid
    end

    urls = %w[http://www.example.com http://example.com https://www.example.com http://blog.example.com http://my.blog.example.com 
              http://example.com/blog http://www.example.com/mysite/blog/ http://example.com/index.html http://example.com/index?q=hello%20world
              http://example.com/posts/5#comments]
    urls.each do |url|
      it "should accept valid urls like '#{url}'" do
        @post.comments.build(@attr.merge(:url => url)).should be_valid
      end
    end

    urls = %w[www.example.com http://www@example.com file://www.example.com]
    urls.each do |url|
      it "should not accept invalid urls like '#{url}'" do
        @post.comments.build(@attr.merge(:url => url)).should_not be_valid
      end
    end

    it "should require a body" do
      @post.comments.build(@attr.merge(:body => " ")).should_not be_valid
    end

    it "should not allow the body to be too long" do
      long_body = "a" * 256
      @post.comments.build(@attr.merge(:body => long_body)).should_not be_valid
    end
  end
end
