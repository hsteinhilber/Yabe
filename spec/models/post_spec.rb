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
    long_title = "a" * 36
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
end
