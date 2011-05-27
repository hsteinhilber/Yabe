require 'spec_helper'

describe PostsController do
  render_views

  def mock_post(stubs={})
    (@mock_post ||= mock_model(Post).as_null_object).tap do |post|
      post.stub(stubs) unless stubs.empty?
      post.stub(:created_at)
    end
  end

  describe "GET index" do

    before(:each) do
      @posts = []
      12.times do |n|
        @posts << Factory(:post, :title => "Post ##{n}")
      end
      @posts = @posts.sort_by { |p| p.created_at }.reverse
    end

    it "assigns 10 posts as @posts" do
      get :index
      assigns(:posts).should == @posts.take(10)
    end

    it "should paginate the posts" do
      get :index
      response.should have_selector("div.pagination")
      response.should have_selector("a", :href => "/posts?page=2")
    end

    context "as atom" do
      it "should return a feed" do
        get :index, :format => :atom
        response.should be_success
      end
    end
  end

  describe "GET show" do    
    before(:each) do
      @post = Factory(:post)
      @c1 = Factory(:comment, :post => @post,
                    :name => "Example Commenter",
                    :email => "commenter@example.com",
                    :body => "Lorem Ipsum Comment!",
                    :created_at => Time.new(2011,5,15,19,0,0))
      @c2 = Factory(:comment, :post => @post, 
                    :name => "Another Commenter", 
                    :email => "second.commenter@example.com", 
                    :body => "Arbitrary Text!", 
                    :created_at => Time.new(2011,5,15,20,0,0)) 
    end

    it "assigns the requested post as @post" do
      get :show, :id => @post.id
      assigns(:post).should == @post
    end

    it "has the right title" do
      get :show, :id => @post.id
      response.should have_selector('title', :content => @post.title)
    end

    it "displays a list of comments" do
      get :show, :id => @post.id
      response.should have_selector('section#comments>header>h1', :content => "Comments")
    end

    it "shows the time of each comment" do
      Time.stub(:now) { Time.new(2011,5,15,20,30,0) }
      get :show, :id => @post.id
      response.should have_selector('time', :content => "about 2 hours ago", :datetime => @c1.created_at.to_s)
      response.should have_selector('time', :content => "30 minutes ago", :datetime => @c2.created_at.to_s)
    end

    it "shows the gravatar for the commenter" do
      get :show, :id => @post.id
      response.should have_selector('img', :class => "gravatar")
    end

    it "shows the commenter's name" do
      get :show, :id => @post.id
      response.should have_selector('h1', :content => @c1.name)
    end

    it "shows the body of the comment" do
      get :show, :id => @post.id
      response.should have_selector("div", :content => @c1.body)
    end

    it "shows the full time when hovering over timestamp" do
      get :show, :id => @post.id 
      response.should have_selector('time', :title => @c1.created_at.localtime.to_s)
    end

    it "links the user's name to their url if provided" do
      @c1.stub(:url) { "http://example.com/commenter" }
      get :show, :id => @post.id
      response.should have_selector('a', :href => @c1.url, :content => @c1.name)
    end

    it "contains an anchor tag for the comments" do
      get :show, :id => @post.id
      response.should have_selector('a', :id => "comment_#{@c1.id}")
    end
  end

  describe "GET new" do

    context 'as an anonymous user' do
      it 'should force the user to log in' do
        get :new
        response.should redirect_to(login_path)
      end
    end

    context 'as an author' do
      before(:each) do
        @author = Factory(:author)
        test_login(@author)
      end

      it 'should be successful' do
        get :new
        response.should be_success
      end

      it 'should have the right title' do
        get :new
        response.should have_selector('title', :content => "New Post")
      end
    end
  end

  describe "GET edit" do
    before(:each) do
      @author = Factory(:author)
      @post = Factory(:post, :author => @author)
    end

    context 'as an anonymous user' do
      it 'should force the user to log in' do
        get :edit, :id => @post.id
        response.should redirect_to(login_path)
      end
    end

    context 'as a different author' do
      before(:each) do
        current_author = Factory(:author, :name => "Another Author", :email => Factory.next(:email))
        test_login(current_author)
      end

      it 'redirects to show page' do
        get :edit, :id => @post.id
        response.should redirect_to(post_path(@post))
      end

      it 'give message stating author cannot edit the post' do
        get :edit, :id => @post.id
        flash[:error].should =~ /cannot edit/i
      end
    end

    context "as the post's author" do
      before(:each) do
        test_login(@author)
      end

      it 'should be successful' do
        get :edit, :id => @post.id
        response.should be_success
      end

      it 'have the correct title' do
        get :edit, :id => @post.id
        response.should have_selector('title', :content => @post.title)
      end
    end

    context 'as an owner' do
      before (:each) do
        owner = Factory(:author, :name => "Owner Author", 
                                 :email => Factory.next(:email),
                                 :owner => true)
        test_login(owner)
      end

      it 'should be successful' do
        get :edit, :id => @post.id
        response.should be_success
      end

      it 'have the correct title' do
        get :edit, :id => @post.id
        response.should have_selector('title', :content => @post.title)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @author = Factory(:author)
      @attr = { :title => "New Post", :body => "Lorem Ipsum Dolor!" }
    end

    context 'as an anonymous user' do
      it 'should force the user to log in' do
        post :create, :post => @attr
        response.should redirect_to(login_path)
      end

      it 'should not create a post' do
        lambda do
          post :create, :post => @attr
        end.should_not change(Post,:count)
      end
    end

    context 'as an author' do
      before(:each) do
        test_login(@author)
      end

      context 'with valid attributes' do
        it 'creates a new post' do
          lambda do
            post :create, :post => @attr
          end.should change(Post, :count).by(1)
        end

        it 'stores the new post in a variable called @post' do
          post :create, :post => @attr
          assigns(:post)
        end

        it 'assigns the correct author to the post' do
          post :create, :post => @attr
          assigns(:post).author_id.should == @author.id
          assigns(:post).author.should == @author
        end
      end

      context 'with invalid attributes' do
        it 'does not create a new post' do
          lambda do
            post :create, :post => @attr.merge(:title => "")
          end.should_not change(Post,:count)
        end

        it "renders the 'new' page" do
          post :create, :post => @attr.merge(:title => "")
          response.should render_template('new')
        end

        it 'has the correct title' do
          post :create, :post => @attr.merge(:title => "")
          response.should have_selector('title', :content => "New Post")
        end
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
