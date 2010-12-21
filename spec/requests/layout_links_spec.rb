require 'spec_helper'

describe "LayoutLinks" do

  it "should have a Posts page at '/'" do
    get '/'
    response.should have_selector('title', :content => "Home")
  end

  it "should have a Contact page at '/contact'" do
    get '/contact'
    response.should have_selector('title', :content => "Contact")
  end

  it "should have an About page at '/about'" do
    get '/about'
    response.should have_selector('title', :content => "About")
  end

  describe "when not logged in" do
    it "should have a log in link" do
      visit root_path
      response.should have_selector("a", :href => login_path,
                                         :content => "Log in")
    end
  end

  describe "when logged in" do
    before(:each) do
      @user = Factory(:user)
      visit login_path
      fill_in :email, :with => @user.email
      fill_in :password, :with => @user.password
      click_button
    end

    it "should have a log out link" do
      visit root_path
      response.should have_selector("a", :href => logout_path,
                                         :content => "Log out")
    end

    it "should have a profile link" do
      visit root_path
      response.should have_selector("a", :href => user_path(@user),
                                         :content => "Profile")
    end
  end
end
