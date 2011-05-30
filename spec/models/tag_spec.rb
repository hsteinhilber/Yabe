require 'spec_helper'

describe Tag do
  before(:each) do
    @attr = { :name => 'Ruby' }
  end

  it 'can be created with valid paramters' do
    Tag.create!(@attr)
  end

  it 'requires a name' do
    tag = Tag.new(@attr.merge(:name => ''))
    tag.should_not be_valid
  end

  it 'validates that name is unique' do
    Tag.create(@attr)
    tag = Tag.new(@attr)
    tag.should_not be_valid
  end

  it 'has a posts method' do
    Tag.new(@attr).should respond_to(:posts)
  end

  it 'should not allow duplicate posts' do
    tag = Factory.next(:tag)
    post = Factory(:post)
    tag.posts = [post, post]
    tag.posts.should == [post]
  end

  describe 'converting from strings' do
    it 'has the correct name' do
      'my tag'.to_tag.name.should == 'my tag'
    end

    it 'is already persisted' do
      'my tag'.to_tag.should_not be_new_record
    end

    it 'loads the correct tag when one already exists' do
      tag_name = 'my tag'
      original = Tag.create(:name => tag_name)
      tag = tag_name.to_tag
      tag.should == original
      tag.id.should == original.id
    end
  end
end
