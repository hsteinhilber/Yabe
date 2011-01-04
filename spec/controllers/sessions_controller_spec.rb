require 'spec_helper'

describe SessionsController do
  render_views

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Login")
    end
  end

  describe "POST 'create'" do
    describe "invalid login" do
      before(:each) do
        @attr = { :email => "author@example.com", :password => "invalid" }
      end

      it "should re-render the 'new' page" do
        post :create, :session => @attr
        response.should render_template(:new)
      end

      it "should have the right title" do
        post :create, :session => @attr
        response.should have_selector("title", :content => "Login")
      end

      it "should have an error message" do
        post :create, :session => @attr
        flash.now[:error].should =~ /invalid/i
      end
    end

    describe "with valid email and password" do
      before(:each) do
        @author = Factory(:author)
        @attr = { :email => @author.email, :password => @author.password }
      end

      it "should log the author in" do
        post :create, :session => @attr
        controller.current_author.should == @author
        controller.should be_logged_in
      end

      it "should redirect to the author show page" do
        post :create, :session => @attr
        response.should redirect_to(author_path(@author))
      end
    end
  end

  describe "DELETE 'destroy'" do

    it "should log a author out" do
      test_login(Factory(:author))
      delete :destroy
      controller.should_not be_logged_in
      response.should redirect_to(root_path)
    end
  end
end
