class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :admin?

  private

  def current_user
    @current_user ||= User.find_by(auth_token: session[:auth_token]) \
      if session[:auth_token]
  end

  def logged_in?
    current_user != nil
  end

  def admin?
    logged_in? && current_user.admin
  end

  def check_for_admin
    redirect_to root_url unless admin?
  end
end
