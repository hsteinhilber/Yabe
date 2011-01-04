class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit, :update]

  def new
    @user = User.new
    @title = "Sign up"
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      login @user
      flash[:success] = "Thank you for signing up!"
      redirect_to @user
    else
      @title = "Sign up"
      @user.password = ""
      @user.password_confirmation = ""
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
    @title = @user.name
  end

  def edit 
    @user = User.find(params[:id])
    @title = "Profile"
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    if @user.save
      flash[:success] = "Your profile has been updated."
      redirect_to @user
    else
      @title = "Profile"
      @user.password = ""
      @user.password_confirmation = ""
      render :edit
    end
  end

  private
    def authenticate
      deny_access unless logged_in?
    end
end
