class AuthorsController < ApplicationController
  before_filter :authenticate, :only => [:edit, :update]
  before_filter :correct_author, :only => [:edit, :update]

  def new
    @author = Author.new
    @title = "Sign up"
  end

  def create
    @author = Author.new(params[:author])
    if @author.save
      login @author
      flash[:success] = "Thank you for signing up!"
      redirect_to @author
    else
      @title = "Sign up"
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
    @authors = Author.all
  end

  private
    def authenticate
      deny_access unless logged_in?
    end

    def correct_author
      @author = Author.find(params[:id])
      redirect_to root_path unless current_author?(@author)
    end
end
