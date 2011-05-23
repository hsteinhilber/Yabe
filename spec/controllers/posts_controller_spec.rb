require 'spec_helper'

describe PostsController do
  render_views

  def mock_post(stubs={})
    (@mock_post ||= mock_model(Post).as_null_object).tap do |post|
      post.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all posts as @posts" do
      Post.stub(:all) { [mock_post] }
      get :index
      assigns(:posts).should eq([mock_post])
    end

    it "displays posts in reverse order of publish date" do
      Post.should_receive(:all)
          .with(:order => "created_at DESC")
          .and_return([mock_post])
      get :index
    end
  end

  describe "GET index as atom" do
    it "should return a feed" do
      Post.stub(:all) { [mock_post] }
      get :index, :format => :atom
      response.should be_success
    end
  end

  describe "GET show" do    
    before(:each) do
      mock_post
      Post.stub(:find).with("37") { mock_post }
      @c1 = mock_model(Comment).as_null_object.tap do |comment|
        comment.stub(:name) { "Example Commenter" }
        comment.stub(:email) { "commenter@example.com" }
        comment.stub(:body) { "Lorem Ipsum Comment!" }
        comment.stub(:created_at) { Time.new(2011,5,15,19,0,0) }
      end
      @c2 = mock_model(Comment).as_null_object.tap do |comment|
        comment.stub(:name) { "Another Commenter" }
        comment.stub(:email) { "second.commenter@example.com" }
        comment.stub(:body) { "Arbitrary Text!" }
        comment.stub(:created_at) { Time.new(2011,5,15,20,0,0) }
      end
      mock_post.stub(:comments) { [@c1,@c2] }
    end

    it "assigns the requested post as @post" do
      get :show, :id => "37"
      assigns(:post).should be(mock_post)
    end

    it "displays a list of comments" do
      get :show, :id => "37"
      response.should have_selector('section#comments>header>h1', :content => "Comments")
    end

    it "shows the time of each comment" do
      Time.stub(:now) { Time.new(2011,5,15,20,30,0) }
      get :show, :id => "37"
      response.should have_selector('time', :content => "about 2 hours ago", :datetime => @c1.created_at.to_s)
      response.should have_selector('time', :content => "30 minutes ago", :datetime => @c2.created_at.to_s)
    end

    it "shows the gravatar for the commenter" do
      get :show, :id => "37"
      response.should have_selector('img', :class => "gravatar")
    end

    it "shows the commenter's name" do
      get :show, :id => "37"
      response.should have_selector('h1', :content => @c1.name)
    end

    it "shows the body of the comment" do
      get :show, :id => "37"
      response.should have_selector("div", :content => @c1.body)
    end

    it "shows the full time when hovering over timestamp" do
      get :show, :id => "37"
      response.should have_selector('time', :title => @c1.created_at.to_s)
    end

    it "links the user's name to their url if provided" do
      @c1.stub(:url) { "http://example.com/commenter" }
      get :show, :id => "37"
      response.should have_selector('a', :href => @c1.url, :content => @c1.name)
    end
  end

  describe "GET new" do
    it "assigns a new post as @post" do
      Post.stub(:new) { mock_post }
      get :new
      assigns(:post).should be(mock_post)
    end
  end

  describe "GET edit" do
    it "assigns the requested post as @post" do
      Post.stub(:find).with("37") { mock_post }
      get :edit, :id => "37"
      assigns(:post).should be(mock_post)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created post as @post" do
        Post.stub(:new).with({'these' => 'params'}) { mock_post(:save => true) }
        post :create, :post => {'these' => 'params'}
        assigns(:post).should be(mock_post)
      end

      it "redirects to the created post" do
        Post.stub(:new) { mock_post(:save => true) }
        post :create, :post => {}
        response.should redirect_to(post_url(mock_post))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved post as @post" do
        Post.stub(:new).with({'these' => 'params'}) { mock_post(:save => false) }
        post :create, :post => {'these' => 'params'}
        assigns(:post).should be(mock_post)
      end

      it "re-renders the 'new' template" do
        Post.stub(:new) { mock_post(:save => false) }
        post :create, :post => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested post" do
        Post.should_receive(:find).with("37") { mock_post }
        mock_post.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :post => {'these' => 'params'}
      end

      it "assigns the requested post as @post" do
        Post.stub(:find) { mock_post(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:post).should be(mock_post)
      end

      it "redirects to the post" do
        Post.stub(:find) { mock_post(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(post_url(mock_post))
      end
    end

    describe "with invalid params" do
      it "assigns the post as @post" do
        Post.stub(:find) { mock_post(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:post).should be(mock_post)
      end

      it "re-renders the 'edit' template" do
        Post.stub(:find) { mock_post(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested post" do
      Post.should_receive(:find).with("37") { mock_post }
      mock_post.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the posts list" do
      Post.stub(:find) { mock_post }
      delete :destroy, :id => "1"
      response.should redirect_to(posts_url)
    end
  end

end
