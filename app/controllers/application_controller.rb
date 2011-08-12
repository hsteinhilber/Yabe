class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  before_filter :get_post_history

  private

    def get_post_history
      @post_history = Post.group(:month, :year).count.map do |p|
        { :month => p[0][0], :year => p[0][1], :month_name => Date::MONTHNAMES[p[0][0]], :post_count => p[1] }
      end
    end
end
