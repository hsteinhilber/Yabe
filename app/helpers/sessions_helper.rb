module SessionsHelper

  def login(author)
    cookies.permanent.signed[:remember_token] = [author.id, author.salt]
    current_author = author
  end

  def logout
    cookies.delete(:remember_token)
    current_author = nil
  end

  def current_author=(author)
    @current_author = author 
  end
    
  def current_author
    @current_author ||= author_from_remember_token 
  end

  def current_author?(author)
    @current_author == author
  end

  def logged_in?
    !current_author.nil?
  end

  def deny_access
    store_location
    redirect_to login_path, :notice => "Please log in to access this page."
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end

  private
    
    def author_from_remember_token
      Author.authenticate_with_salt(*remember_token)
    end

    def remember_token
      cookies.signed[:remember_token] || [nil, nil]
    end

    def store_location
      session[:return_to] = request.fullpath
    end

    def clear_return_to
      session[:return_to] = nil
    end
end
