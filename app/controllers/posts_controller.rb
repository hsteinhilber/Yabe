class PostsController < ApplicationController
  before_filter :authenticate, :only => [:new, :edit, :create, :update]
  before_filter :correct_author, :only => [:edit, :update]

  # GET /posts
  # GET /posts.xml
  def index
    @title = "Home"
    @posts = Post.paginate(:page => params[:page], :per_page => 10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
      format.json { render :json => @posts }
      format.atom # index.atom.builder
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @post = Post.find(params[:id])
    @title = @post.title

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
      format.json { render :json => @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.xml
  def new
    @post = Post.new
    @title = "New Post"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post }
      format.json { render :json => @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
    @title = @post.title
  end

  # POST /posts
  # POST /posts.xml
  def create
    @post = current_author.posts.build(params[:post])

    respond_to do |format|
      if @post.save
        format.html { redirect_to(@post, :flash => {:success => 'Post was successfully created.' } ) }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
        format.json { render :json => @post, :status => :created, :location => @post }
      else
        @title = "New Post"
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
        format.json { render :json => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post = Post.find(params[:id])
    @title = @post.title

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to(@post, :flash => { :success => 'Post was successfully updated.' } ) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
        format.json { render :json => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to(posts_url) }
      format.xml  { head :ok }
    end
  end

  private 
    def authenticate
      redirect_to login_path unless logged_in?
    end

    def correct_author
      @post = Post.find(params[:id])
      unless current_author?(@post.author) || current_author.owner?
        flash[:error] = "You cannot edit posts that do not belong to you."
        redirect_to @post
      end
    end
end
