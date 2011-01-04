class UsersController < ApplicationController
  before_filter :authenticate, :only => [:edit, :update]
  before_filter :correct_user, :only => [:edit, :update]

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
    @title = "Profile"
  end

  def update
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

    def correct_user
      @user = User.find(params[:id])
      redirect_to root_path unless current_user?(@user)
    end
end
