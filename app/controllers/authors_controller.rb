class AuthorsController < ApplicationController
  before_filter :authenticate, :except => [:show, :index]
  before_filter :correct_author, :only => [:edit, :update]
  before_filter :owner_only, :only => [:new, :create, :destroy]

  def new
    @author = Author.new
    @title = "New Author"
  end

  def create
    @author = Author.new(params[:author])
    if @author.save
      login @author
      flash[:success] = "Welcome our new author!"
      redirect_to @author
    else
      @title = "New Author"
      @author.password = ""
      @author.password_confirmation = ""
      render :new
    end
  end

  def show
    @author = Author.find(params[:id])
    @title = @author.name
  end

  def edit 
    @title = "Profile"
  end

  def update
    @author.update_attributes(params[:author])
    if @author.save
      flash[:success] = "Your profile has been updated."
      redirect_to @author
    else
      @title = "Profile"
      @author.password = ""
      @author.password_confirmation = ""
      render :edit
    end
  end

  def index
    @title = "Authors"
    @authors = Author.paginate(:page => params[:page], :per_page => 10)
  end

  def destroy
    Author.find(params[:id]).destroy
    flash[:success] = "Author has been deleted."
    redirect_to authors_path
  end

  private
    def authenticate
      deny_access unless logged_in?
    end

    def correct_author
      @author = Author.find(params[:id])
      redirect_to root_path unless current_author?(@author)
    end

    def owner_only
      redirect_to(root_path) unless current_author.owner?
    end
end
