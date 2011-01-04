class SessionsController < ApplicationController
  def new
    @title = "Login"
  end

  def create
    author = Author.authenticate(params[:session][:email],
                             params[:session][:password])
    if author.nil?
      flash.now[:error] = "Invalid email address or password."
      @title = "Login"
      render :new
    else
      login author
      redirect_back_or author
    end
  end

  def destroy
    logout
    redirect_to root_path
  end

end
