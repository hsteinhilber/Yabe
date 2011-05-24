require 'spec_helper'

describe Post do
  before(:each) do
    @attr = { :title => "My Awesome Post", :body => "Some really awesome content" }
  end

  it "should create a new instance given valid attributes" do
    Post.create!(@attr)
  end

  it "should require a title" do
    no_title_post = Post.new(@attr.merge(:title => ""))
    no_title_post.should_not be_valid
  end

  it "should reject titles that are too long" do
    long_title = "a" * 76
    long_title_post = Post.new(@attr.merge(:title => long_title))
    long_title_post.should_not be_valid
  end

  it "should require the body" do
    no_body_post = Post.new(@attr.merge(:body => ""))
    no_body_post.should_not be_valid
  end

  it "should allow really long strings" do
    long_body = "a" * 5000
    long_body_post = Post.new(@attr.merge(:body => long_body))
    long_body_post.should be_valid
  end

  describe "association with comments" do

    before(:each) do
      @post = Post.create(@attr)
      @comment1 = Factory(:comment, :post => @post, :created_at => 1.hour.ago)
      @comment2 = Factory(:comment, :post => @post, :created_at => 1.day.ago)
    end

    it "should have a comments attribute" do
      @post.should respond_to(:comments)
    end

    it "should order comments from the oldest to the newest" do
      @post.comments.should == [@comment2, @comment1]
    end

    it "should destroy related comments" do
      @post.destroy
      [@comment1, @comment2].each do |comment|
        Comment.find_by_id(comment.id).should be_nil
      end
    end
  end
end
