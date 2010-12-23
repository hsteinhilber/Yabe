class UsersController < ApplicationController
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
    @title = @user.name
  end
end
