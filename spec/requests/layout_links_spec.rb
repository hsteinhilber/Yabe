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

  describe "when logged in" do
    before(:each) do
      @author = Factory(:author)
      integration_login @author
    end

    it "should have a log out link" do
      visit root_path
      response.should have_selector("a", :href => logout_path,
                                         :content => "Logout")
    end

    it "should have a profile link" do
      visit root_path
      response.should have_selector("a", :href => author_path(@author),
                                         :content => "Profile")
    end
  end
end
