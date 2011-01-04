require 'spec_helper'

describe "FriendlyForwardings" do
  it "should forward to the requested page after login" do
    author = Factory(:author)
    visit edit_author_path(author)
    fill_in :email, :with => author.email
    fill_in :password, :with => author.password
    click_button
    response.should render_template('authors/edit')
  end
end
