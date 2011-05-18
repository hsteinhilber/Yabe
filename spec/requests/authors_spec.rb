require 'spec_helper'

describe "Authors" do
  describe "created by owner" do
    before(:each) do
      owner = Factory(:author, :email => "owner@example.com", :owner => true)
      integration_login(owner)
    end

    describe "failure" do
      it "should not make a new author" do
        lambda do
          visit '/authors/new'
          fill_in "Name", :with => ""
          fill_in "Email", :with => ""
          fill_in "Password", :with => ""
          fill_in "Confirm", :with => ""
          click_button
          response.should render_template('authors/new')
          response.should have_selector("div#error_explanation")
        end.should_not change(Author, :count)
      end
    end

    describe "success" do
      it "should create a new author" do
        lambda do
          visit '/authors/new'
          fill_in "Name", :with => "Example Author"
          fill_in "Email", :with => "author@example.com"
          fill_in "Password", :with => "secret"
          fill_in "Confirm", :with => "secret"
          click_button
          response.should have_selector(".flash div.success", :content => "Welcome")
          response.should render_template('authors/show')
        end.should change(Author, :count).by(1)
      end
    end
  end
end
