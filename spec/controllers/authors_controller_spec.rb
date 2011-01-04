require 'spec_helper'

describe AuthorsController do
  render_views

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end

    it "should have the right title" do
      get 'new'
      response.should have_selector("title", :content => "Sign up")
    end
  end

  describe "GET 'show'" do
    before(:each) do
      @author = Factory(:author)
    end

    it "should be successful" do
      get :show, :id => @author 
      response.should be_success
    end

    it "should find the right author" do
      get :show, :id => @author
      assigns(:author).should == @author
    end

    it "should have the right title" do
      get :show, :id => @author
      response.should have_selector("title", :content => @author.name)
    end

    it "should show the author's name" do
      get :show, :id => @author
      response.should have_selector("h1", :content => @author.name)
    end

    it "should have a profile image" do
      get :show, :id => @author
      response.should have_selector("h1>img", :class => "gravatar")
    end
  end

  describe "POST 'create'" do
    describe "failure" do
      before(:each) do
        @attr = { :name => "", :email => "", :password => "bad", :password_confirmation => "invalid" }
      end

      it "should not create a author" do
        lambda do
          post :create, :author => @attr
        end.should_not change(Author, :count)
      end

      it "should have the right title" do 
        post :create, :author => @attr
        response.should have_selector("title", :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, :author => @attr
        response.should render_template('new')
      end

      it "should clear the password" do
        post :create, :author => @attr
        assigns(:author).password.should be_empty
      end

      it "should clear the confirmation" do
        post :create, :author => @attr
        assigns(:author).password_confirmation.should be_empty
      end
    end
    
    describe "success" do
      before(:each) do
        @attr = { :name => "New Author", :email => "new.author@example.com",
          :password => "secret", :password_confirmation => "secret" }
      end

      it "should create a author" do
        lambda do
          post :create, :author => @attr
        end.should change(Author, :count).by(1)
      end

      it "should redirect to the author show page" do
        post :create, :author => @attr
        response.should redirect_to(author_path(assigns(:author)))
      end

      it "should have a welcome message" do
        post :create, :author => @attr
        flash[:success].should =~ /thank you/i
      end

      it "should log the author in" do
        post :create, :author => @attr
        controller.should be_logged_in
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      @author = Factory(:author)
      test_login(@author)
    end

    it "should be successful" do
      get :edit, :id => @author
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @author
      response.should have_selector("title", :content => "Profile")
    end

    it "should have a link to change Gravatar image" do
      GravatarUrl = "http://gravatar.com/emails"
      get :edit, :id => @author
      response.should have_selector("a", :href => GravatarUrl)
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      @author = Factory(:author)
      test_login(@author)
    end

    describe "failure" do
      before(:each) do
        @attr = { :email => "", :name => "", 
          :password => "junk", :password_confirmation => "invalid" }
      end

      it "should render the 'edit' page'" do
        put :update, :id => @author, :author => @attr
        response.should render_template(:edit)
      end

      it "should have the right title" do
        put :update, :id => @author, :author => @attr
        response.should have_selector("title", :content => "Profile")
      end

      it "should clear the password fields" do
        put :update, :id => @author, :author => @attr
        assigns(:author).password.should be_empty
        assigns(:author).password_confirmation.should be_empty
      end
    end

    describe "success" do
      before(:each) do
        @attr = { :name => "New Name", :email => "updated.author@example.com",
          :password => "newpassword", :password_confirmation => "newpassword" }
      end

      it "should change the author's attributes" do
        put :update, :id => @author, :author => @attr
        @author.reload
        @author.name.should == @attr[:name]
        @author.email.should == @attr[:email]
      end

      it "should redirect to the author show page" do
        put :update, :id => @author, :author => @attr
        response.should redirect_to(author_path(@author))
      end

      it "should have a flash message" do
        put :update, :id => @author, :author => @attr
        flash[:success].should =~ /updated/
      end
    end
  end

  describe "authentication of edit/update pages" do
    before(:each) do
      @author = Factory(:author)
    end

    describe "for non-logged-in authors" do
      it "should deny access to 'edit'" do
        get :edit, :id => @author
        response.should redirect_to(login_path)
      end

      it "should deny access to 'update'" do
        put :update, :id => @author, :author => {}
        response.should redirect_to(login_path)
      end
    end

    describe "for logged-in authors" do
      before(:each) do
        wrong_author = Factory(:author, :email => "wrong.author@example.com")
        test_login(wrong_author)
      end

      it "should redirect to root if wrong author attempts to 'edit'" do
        get :edit, :id => @author
        response.should redirect_to(root_path)
      end

      it "should redirect to root if wrong author attempts to 'update'" do
        put :update, :id => @author, :author => {}
        response.should redirect_to(root_path)
      end
    end
  end
end
