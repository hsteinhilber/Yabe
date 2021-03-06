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

  it "should sort in descending order by published_on by default" do
    posts = 10.times.map do |n|
      Factory(:post, :title => "Post ##{n}", :published_on => n.minutes.ago)
    end.sort_by { |p| p.published_on }.reverse
    Post.all.should == posts
  end

  it "should allow really long strings" do
    long_body = "a" * 5000
    long_body_post = Post.new(@attr.merge(:body => long_body))
    long_body_post.should be_valid
  end

  describe 'publication date' do
    it 'exists' do
      post = Post.new(@attr)
      post.should respond_to(:published_on)
    end

    it 'defaults to the current date/time if saved without one' do
      expected = Time.new(2011, 1, 1, 8, 0, 0)
      Time.stub(:now) { expected }
      post = Post.create(@attr)
      post.reload
      post.published_on.should == expected
    end

    it 'is not modified if set by user' do
      expected = Time.new(2011, 1, 4, 8, 0, 0)
      Time.stub(:now) { Time.new(2011, 1, 1, 0, 0, 0) }
      post = Post.create(@attr.merge(:published_on => expected))
      post.reload
      post.published_on.should == expected
    end

    it 'sets the month filter attribute' do
      published = Time.new(2011, 7, 2, 9, 30, 0)
      post = Post.create(@attr.merge(:published_on => published))
      post.month.should == 7
    end

    it 'sets the year filter attribute' do
      published = Time.new(2011, 7, 2, 9, 30, 0)
      post = Post.create(@attr.merge(:published_on => published))
      post.year.should == 2011 
    end

    it 'filters out dates in the future' do
      future_post = Post.create(@attr.merge(:published_on => 1.minute.from_now))
      Post.all.should_not include(future_post)
    end
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

  describe 'association with author' do
    
    before(:each) do 
      @author = Factory(:author)
      @post = @author.posts.create(@attr)
    end

    it "should have an author attribute" do
      @post.should respond_to(:author)
    end

    it "should be associated with the corrct author" do
      @post.author_id.should == @author.id
      @post.author.should == @author
    end
  end

  describe 'association with tag' do
    before(:each) do 
      @post = Factory(:post)
      @tag = Factory.next(:tag)
    end

    it 'should have a tags attribute' do
      @post.should respond_to(:tags)
    end

    it 'should not allow multiple tags with the same name' do
      @post.tags = [@tag, @tag]
      @post.tags.should == [@tag]
    end

    it 'assigns the proper tags when given tag_tokens' do
      unused = Factory.next(:tag)
      tag2 = Factory.next(:tag)
      @post.tag_tokens = "#{@tag.id},#{tag2.id}"
      @post.tags.should =~ [@tag, tag2]
    end

    it 'creates a new tag when encountering a token id like "[name]"' do
      @post.tag_tokens = '[FooBar]'
      new_tag = Tag.find_by_name('FooBar')
      new_tag.should_not be_nil
      @post.tags.should include(new_tag)
    end

    it 'creates multiple tags when encounting multiple add token ids' do
      @post.tag_tokens = '[Hello],[World]'
      tag1, tag2 = Tag.find_by_name('Hello'), Tag.find_by_name('World')
      tag1.should_not be_nil
      tag2.should_not be_nil
      @post.tags.should =~ [tag1, tag2]
    end
  end

  describe 'slugs' do
    before(:each) do
      @post = Factory(:post, :title => 'My Basic Title')
    end

    it 'responds to slug' do
      @post.should respond_to(:slug)
    end

    it 'has a slug based on it\'s title' do
      @post.slug.name.should == 'my-basic-title'
    end
  end
end
