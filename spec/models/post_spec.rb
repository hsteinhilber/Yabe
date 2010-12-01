require 'spec_helper'

describe Post do
  before(:each) do
    @attr = { :title => "My Awesome Post", :body => "Some really awesome content" }
  end

  it "should create a new instance given valid attributes" do
    Post.create!(@attr)
  end

  it "should require a title"
end
