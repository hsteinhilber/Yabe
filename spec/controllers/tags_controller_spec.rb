require 'spec_helper'

describe TagsController do
  render_views

  describe "GET 'index'" do
    before(:each) do
      Tag.create!(:name => "Ruby")
      Tag.create!(:name => "Rails")
      Tag.create!(:name => "Other")
    end

    it "should be successful" do
      get 'index', :format => 'json'
      response.should be_success
    end

    it "should return the proper json" do
      get 'index', :format => 'json'
      response.body.should =~ /"name":"Ruby"/
      response.body.should =~ /"name":"Rails"/
      response.body.should =~ /"name":"Other"/
    end

    it "should not include the type" do
      get 'index', :format => 'json'
      response.body.should_not =~ /"tag":{/
    end

    it "can filter tags that contains text" do
      get 'index', :format => 'json', :q => "ub"
      response.body.should =~ /"name":"Ruby"/
      response.body.should_not =~ /"name":"Rails"/
      response.body.should_not =~ /"name":"Other"/
    end

    it "only returns the first ten results" do
      15.times { Factory.next(:tag) }
      get 'index', :format => 'json', :q => "tag"
      response.body.scan('{"id":').length.should == 10
    end

    it 'contains an option to add the text if no match' do
      get 'index', :format => 'json', :q => 'win'
      response.body.should =~ /"name":"Add - win"/
    end

    it 'does not contain option to add if match exists' do
      get 'index', :format => 'json', :q => 'ruby'
      response.body.should_not =~ /"name":"Add - ruby"/
    end
  end

end
