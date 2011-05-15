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
end
