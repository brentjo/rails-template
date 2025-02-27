class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def logged_in?
    !!(current_user)
  end
  helper_method :logged_in?

  def require_authenticated_user
    redirect_to login_url unless current_user
  end

  def compare_with_real_token(token, session)
    false
  end

  def compare_with_global_token(token, session)
    false
  end

end
