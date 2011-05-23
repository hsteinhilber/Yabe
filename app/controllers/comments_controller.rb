class CommentsController < ApplicationController

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(params[:comment])
    if @comment.save
      flash[:success] = "Thank you for your comment!"
      redirect_to post_path(@post, :anchor => "comment_#{@comment.id}")
    else
      @post.comments.delete @comment
      render 'posts/show'
    end
  end

  def destroy

  end
end
