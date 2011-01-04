require 'spec_helper'

describe "Sessions" do
  describe "logging in" do
    describe "failure" do
      it "does not log a author in" do
        visit login_path
        fill_in :email, :with => ""
        fill_in :password, :with => ""
        click_button
        response.should have_selector("div.error", :content => "Invalid")
        controller.should_not be_logged_in
      end
    end

    describe "success" do
      it "logs the author in" do
        author = Factory(:author)
        visit login_path
        fill_in :email, :with => author.email
        fill_in :password, :with => author.password
        click_button
        controller.should be_logged_in
      end
    end
  end

  describe "logging out" do
    it "should log the author out" do
      author = Factory(:author)
      integration_login author
      visit root_path
      click_link "Logout"
      controller.should_not be_logged_in
    end
  end
end
