class ApplicationController < ActionController::Base
  require 'csv'

  helper_method :current_session, :current_user, :logged_in?

  def current_session
    @current_session ||= session if session
  end
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_user
    if !logged_in?
      flash[:danger] = "You must login first"
      redirect_to root_path
    end
  end
end
