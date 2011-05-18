require 'spec_helper'

describe AuthorsController do
  render_views

  describe "GET 'new'" do
    before (:each) do
      @author = Factory(:author)
    end

    describe "as a non-logged-in user" do
      it "should deny access" do
        delete :destroy, :id => @author
        response.should redirect_to(login_path)
      end

      it "should not destroy the user" do
        lambda do
          delete :destroy, :id => @author
        end.should_not change(Author, :count)
      end
   end

    describe "as a non-owner user" do
      it "should protect the page" do
        test_login(@author)
        delete :destroy, :id => @author
        response.should redirect_to(root_path)
      end

      it "should not destroy the user" do
        lambda do
          delete :destroy, :id => @author
        end.should_not change(Author, :count)
      end
    end

    describe "as an owner user" do
      before(:each) do
        owner = Factory(:author, :email => "author@example.com", :owner => true)
        test_login(owner)
      end

      it "should be successful" do
        get 'new'
        response.should be_success
      end

      it "should have the right title" do
        get 'new'
        response.should have_selector("title", :content => "New Author")
      end
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
    before (:each) do
      @author = Factory(:author)
    end

    describe "as a non-logged-in user" do
      it "should deny access" do
        delete :destroy, :id => @author
        response.should redirect_to(login_path)
      end

      it "should not destroy the user" do
        lambda do
          delete :destroy, :id => @author
        end.should_not change(Author, :count)
      end
   end

    describe "as a non-owner user" do
      it "should protect the page" do
        test_login(@author)
        delete :destroy, :id => @author
        response.should redirect_to(root_path)
      end

      it "should not destroy the user" do
        lambda do
          delete :destroy, :id => @author
        end.should_not change(Author, :count)
      end
    end

    describe "as an owner user" do
      before(:each) do
        owner = Factory(:author, :email => "author@example.com", :owner => true)
        test_login(owner)
      end

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
          response.should have_selector("title", :content => "New Author")
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

        it "should redirect to the authors index page" do
          post :create, :author => @attr
          response.should redirect_to(authors_path)
        end

        it "should have a welcome message" do
          post :create, :author => @attr
          flash[:success].should =~ /welcome/i
        end
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

  describe "GET 'index'" do
    before(:each) do
      @author = Factory(:author)
      second = Factory(:author, :email => "second.user@example.com")
      third = Factory(:author, :email => "third.user@example.com")

      @authors = [@author, second, third]
      10.times do
        @authors << Factory(:author, :email => Factory.next(:email))
      end
    end

    it "should be successful" do
      get :index
      response.should be_success
    end

    it "should have the right title" do
      get :index
      response.should have_selector('title', :content => "Authors")
    end

    it "should have an element for each author" do
      get :index
      @authors[0..2].each do |author|
        response.should have_selector('li', :content => author.name)
      end
    end

    it "should paginate the authors" do
      get :index
      response.should have_selector("div.pagination")
      response.should have_selector("span.disabled", :content => "Previous")
      response.should have_selector("a", :href => "/authors?page=2",
                                         :content => "2")
      response.should have_selector("a", :href => "/authors?page=2",
                                         :content => "Next")
    end
  end

  describe "DELETE 'destroy'" do
    before (:each) do
      @author = Factory(:author)
    end

    describe "as a non-logged-in user" do
      it "should deny access" do
        delete :destroy, :id => @author
        response.should redirect_to(login_path)
      end

      it "should not destroy the user" do
        lambda do
          delete :destroy, :id => @author
        end.should_not change(Author, :count)
      end
   end

    describe "as a non-owner user" do
      it "should protect the page" do
        test_login(@author)
        delete :destroy, :id => @author
        response.should redirect_to(root_path)
      end

      it "should not destroy the user" do
        lambda do
          delete :destroy, :id => @author
        end.should_not change(Author, :count)
      end
    end

    describe "as an owner user" do
      before(:each) do
        owner = Factory(:author, :email => "author@example.com", :owner => true)
        test_login(owner)
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @author
        end.should change(Author, :count).by(-1)
      end

      it "should redirect to the authors page" do
        delete :destroy, :id => @author
        response.should redirect_to(authors_path)
      end
    end
  end
end
