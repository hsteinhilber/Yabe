require 'spec_helper'

describe UsersController do
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
      @user = Factory(:user)
    end

    it "should be successful" do
      get :show, :id => @user 
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end

    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector("title", :content => @user.name)
    end

    it "should show the user's name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end

    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end
  end

  describe "POST 'create'" do
    describe "failure" do
      before(:each) do
        @attr = { :name => "", :email => "", :password => "bad", :password_confirmation => "invalid" }
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it "should have the right title" do 
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end

      it "should clear the password" do
        post :create, :user => @attr
        assigns(:user).password.should be_empty
      end

      it "should clear the confirmation" do
        post :create, :user => @attr
        assigns(:user).password_confirmation.should be_empty
      end
    end
    
    describe "success" do
      before(:each) do
        @attr = { :name => "New User", :email => "new.user@example.com",
          :password => "secret", :password_confirmation => "secret" }
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end

      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /thank you/i
      end

      it "should log the user in" do
        post :create, :user => @attr
        controller.should be_logged_in
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      @user = Factory(:user)
      test_login(@user)
    end

    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Profile")
    end

    it "should have a link to change Gravatar image" do
      GravatarUrl = "http://gravatar.com/emails"
      get :edit, :id => @user
      response.should have_selector("a", :href => GravatarUrl)
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      @user = Factory(:user)
      test_login(@user)
    end

    describe "failure" do
      before(:each) do
        @attr = { :email => "", :name => "", 
          :password => "junk", :password_confirmation => "invalid" }
      end

      it "should render the 'edit' page'" do
        put :update, :id => @user, :user => @attr
        response.should render_template(:edit)
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Profile")
      end

      it "should clear the password fields" do
        put :update, :id => @user, :user => @attr
        assigns(:user).password.should be_empty
        assigns(:user).password_confirmation.should be_empty
      end
    end

    describe "success" do
      before(:each) do
        @attr = { :name => "New Name", :email => "updated.user@example.com",
          :password => "newpassword", :password_confirmation => "newpassword" }
      end

      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should == @attr[:name]
        @user.email.should == @attr[:email]
      end

      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end
end
