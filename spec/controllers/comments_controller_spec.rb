require 'spec_helper'

describe CommentsController do
  render_views

  before(:each) do
    @post = Factory(:post)
    @attr = {
      :name => "Example Commenter",
      :email => "commenter@example.com",
      :url => "http://www.example.com/commenter",
      :body => "Lorem Ipsum Dolor Comment Text"
    }
  end

  describe "POST create" do

    describe "with valid params" do

      it "creates a new comment" do
        lambda do
          post :create, :post_id => @post.id, :comment => @attr
        end.should change(Comment,:count).by(1)
      end

      it "associates the comment with the correct post" do
        post :create, :post_id => @post.id, :comment => @attr
        @post.comments.first.post_id.should == @post.id
      end

      it "redirects to the posts page and scrolls to the comment" do
        post :create, :post_id => @post.id, :comment => @attr
        comment_id = @post.comments.first.id
        response.should redirect_to(post_path(@post, :anchor => "comment_#{comment_id}"))
      end

      it "displays a thank you message to the user" do
        post :create, :post_id => @post.id, :comment => @attr
        flash[:success].should =~ /thank you/i
      end
    end

    describe "with invalid params" do

      before(:each) do
        @attr.merge! :email => "bad email"
      end

      it "does not create a new comment" do
        lambda do
          post :create, :post_id => @post.id, :comment => @attr
        end.should_not change(Comment, :count)
      end

      it "does not add the comment to the posts list of comments" do
        lambda do
          post :create, :post_id => @post.id, :comment => @attr
        end.should_not change(@post.comments, :count)
      end

      it "renders the post" do
        post :create, :post_id => @post.id, :comment => @attr
        response.should render_template('posts/show')
      end

      it "displays an error message" do
        post :create, :post_id => @post.id, :comment => @attr
        response.should have_selector("div", :id => "error_explanation")
      end

      it "maintains the contents of the form" do
        post :create, :post_id => @post.id, :comment => @attr
        comment = assigns(:comment)
        response.should have_selector("input", :value => comment.name)
        response.should have_selector("input", :value => comment.email)
        response.should have_selector("input", :value => comment.url)
        response.should have_selector("textarea", :content => comment.body)
      end
    end

  end

  describe "DELETE destroy" do
    
    describe "as an anonymous user" do

      it "redirects to the login page"
    end

    describe "as the post author" do

      it "destroys the requested comment"

      it "redirects to the post's page"
    end

    describe "as another author" do

      it "redirects to the post's page and scrolls to the comment"

      it "displays an error message to the author"
    end
  end

end
