require 'spec_helper'

describe PostsController do
  render_views

  describe "GET index" do

    before(:each) do
      @posts = 12.times.map do |n|
        Factory(:post, :title => "Post ##{n}", :published_on => Time.now - n)
      end.sort_by { |p| p.published_on }.reverse
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

    it "should display a link to create posts to authors" do
      test_login(Factory(:author))
      get :index
      response.should have_selector('a', :href => new_post_path)
    end

    it 'should not display new post link if not logged in' do
      get :index
      response.should_not have_selector('a', :href => new_post_path)
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
      @author = Factory(:author)
      @post = Factory(:post, :author => @author)
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

    it "contains a list of tags" do
      tag = Factory.next(:tag)
      @post.tags << tag
      get :show, :id => @post.id
      response.should have_selector('li', :content => tag.name)
    end

    it "contains the publication date/time" do
      Time.stub(:now) { Time.new(2011,1,2,11,30,0) }
      (@post.published_on = Time.new(2011,1,1,9,30,0)) && @post.save!
      get :show, :id => @post.id
      response.should have_selector('time', :content => "1 day ago", :datetime => @post.published_on.to_s)
      response.should have_selector('time', :title => @post.published_on.localtime.to_s)
    end

    it "contains the date the the post was originally created" do
      Time.stub(:now) { Time.new(2011,1,4,11,30,0) }
      (@post.created_at = Time.new(2011,1,3,9,30,0)) && @post.save!
      get :show, :id => @post.id
      response.should have_selector('time', :content => "1 day ago", :datetime => @post.created_at.to_s)
      response.should have_selector('time', :title => @post.created_at.localtime.to_s)
    end

    it "contains the name of the author" do
      get :show, :id => @post.id
      response.should have_selector('span', :content => @author.name)
    end

    context 'as an anonymous user' do
      it 'should not show the post edit link' do
        get :show, :id => @post.id
        response.should_not have_selector('a', :href => edit_post_path(@post))
      end

      it 'should not show the post destroy link' do
        get :show, :id => @post.id
        response.should_not have_selector('a', :href => post_path(@post), :content => 'Delete')
      end
    end

    context 'as a different author' do
      before(:each) do
        author = Factory(:author, :email => Factory.next(:email))
        test_login(author)
      end

      it 'should not show the post edit link' do
        get :show, :id => @post.id
        response.should_not have_selector('a', :href => edit_post_path(@post))
      end

      it 'should not show the post destroy link' do
        get :show, :id => @post.id
        response.should_not have_selector('a', :href => post_path(@post), :content => 'Delete')
      end
    end

    context 'as the post author' do
      before(:each) do
        test_login(@author)
      end

      it 'should show the post edit link' do
        get :show, :id => @post.id
        response.should have_selector('a', :href => edit_post_path(@post))
      end

      it 'should show the post destroy link' do
        get :show, :id => @post.id
        response.should have_selector('a', :href => post_path(@post), :content => 'Delete')
      end
    end

    context 'as an owner' do
      before(:each) do
        owner = Factory(:author, :email => Factory.next(:email), :owner => true)
        test_login(owner)
      end

      it 'should show the post edit link' do
        get :show, :id => @post.id
        response.should have_selector('a', :href => edit_post_path(@post))
      end

      it 'should show the post destroy link' do
        get :show, :id => @post.id
        response.should have_selector('a', :href => post_path(@post), :content => 'Delete')
      end
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
        current_author = Factory(:author, :name => "another author", :email => Factory.next(:email))
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

      it 'has the correct title' do
        get :edit, :id => @post.id
        response.should have_selector('title', :content => @post.title)
      end

      it 'prefills tag information' do
        tag = Factory.next(:tag)
        @post.tags = [tag]
        json = "[{\"id\":#{tag.id},\"name\":\"#{tag.name}\",\"post_id\":#{@post.id},\"tag_id\":#{tag.id}}]"
        get :edit, :id => @post.id
        response.should have_selector('input', 
                                      :id => 'post_tag_tokens', 
                                      'data-pre' => json)
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

      it 'has the correct title' do
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
    before(:each) do
      @author = Factory(:author)
      @post = Factory(:post, :author => @author)
      @attr = { :title => "New Post", :body => "Lorem Ipsum Dolor!" }
    end

    context 'as an anonymous user' do
      it "should force the user to log in" do
        put :update, :id => @post.id, :post => @attr
        response.should redirect_to(login_path)
      end
    end

    context 'as a different author' do
      before(:each) do
        current_author = Factory(:author, :name => "another author", :email => Factory.next(:email))
        test_login(current_author)
      end

      it 'redirects to show page' do
        get :update, :id => @post.id, :post => @attr
        response.should redirect_to(post_path(@post))
      end

      it 'give message stating author cannot edit the post' do
        get :update, :id => @post.id, :post => @attr
        flash[:error].should =~ /cannot edit/i
      end
    end

    context "as the post's author" do
      before(:each) do
        test_login(@author)
      end

      context 'with valid attributes' do
        it "should change the post's attributes" do
          put :update, :id => @post.id, :post => @attr
          @post.reload
          @post.title.should == @attr[:title]
          @post.body.should == @attr[:body]
        end

        it "should have a message saying it was updated" do
          put :update, :id => @post.id, :post => @attr
          flash[:success].should =~ /updated/
        end

        it "should redirect to the post show page" do
          put :update, :id => @post.id, :post => @attr
          response.should redirect_to(post_path(@post))
        end
      end

      context 'with invalid attributes' do
        it "should not change the post's attributes" do
          put :update, :id => @post.id, :post => @attr.merge(:title => "")
          @post.reload
          @post.body.should_not == @attr[:body]
        end

        it "should have the right title" do
          put :update, :id => @post.id, :post => @attr.merge(:title => "")
          response.should have_selector('title', :content => @post.title)
        end

        it "should render the edit view" do
          put :update, :id => @post.id, :post => @attr.merge(:title => "")
          response.should render_template('edit')
        end
      end
    end

    context "as an owner" do
      before(:each) do
        owner = Factory(:author, :email => Factory.next(:email), :owner => true)
        test_login(owner)
      end

      context 'with valid attributes' do
        it "should change the post's attributes" do
          put :update, :id => @post.id, :post => @attr
          @post.reload
          @post.title.should == @attr[:title]
          @post.body.should == @attr[:body]
        end

        it "should have a message saying it was updated" do
          put :update, :id => @post.id, :post => @attr
          flash[:success].should =~ /updated/
        end

        it "should redirect to the post show page" do
          put :update, :id => @post.id, :post => @attr
          response.should redirect_to(post_path(@post))
        end
      end

      context 'with invalid attributes' do
        it "should not change the post's attributes" do
          put :update, :id => @post.id, :post => @attr.merge(:title => "")
          @post.reload
          @post.body.should_not == @attr[:body]
        end

        it "should have the right title" do
          put :update, :id => @post.id, :post => @attr.merge(:title => "")
          response.should have_selector('title', :content => @post.title)
        end

        it "should render the edit view" do
          put :update, :id => @post.id, :post => @attr.merge(:title => "")
          response.should render_template('edit')
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @author = Factory(:author)
      @post = Factory(:post, :author => @author)
    end

    context 'as an anonymous user' do
      it 'should not destroy the post' do
        lambda do
          delete :destroy, :id => @post.id
        end.should_not change(Post,:count)
      end

      it 'should force the user to log in' do
        delete :destroy, :id => @post.id
        response.should redirect_to(login_path)
      end
    end

    context 'as a different author' do
      before(:each) do
        second_author = Factory(:author, :email => Factory.next(:email))
        test_login(second_author)
      end

      it 'does not destroy the post' do
        lambda do
          delete :destroy, :id => @post.id
        end.should_not change(Post,:count)
      end

      it 'redirects to the show view' do
        delete :destroy, :id => @post.id
        response.should redirect_to(post_path(@post))
      end
    end

    context "as a post's author" do
      before(:each) do
        test_login(@author)
      end

      it "destroys the requested post" do
        delete :destroy, :id => @post.id
        Post.find_by_id(@post.id).should be_nil
      end

      it "redirects to the posts list" do
        delete :destroy, :id => @post.id
        response.should redirect_to(posts_path)
      end
    end

    context 'as an owner' do
      before(:each) do
        owner = Factory(:author, :email => Factory.next(:email), :owner => true)
        test_login(owner)
      end

      it "destroys the requested post" do
        delete :destroy, :id => @post.id
        Post.find_by_id(@post.id).should be_nil
      end

      it "redirects to the posts list" do
        delete :destroy, :id => @post.id
        response.should redirect_to(posts_path)
      end
    end
  end
end
