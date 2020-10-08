class UsersController < ApplicationController

  def new
    if logged_in?
      redirect_to '/'
    else
      render 'users/new'
    end
  end

  def create
    if logged_in?
      redirect_to '/' and return
    end

    user = User.new(user_creation_params)
    if user.save
      session[:user_id] = user.id
      flash[:success] = "Your account has been created."
      redirect_to root_url
    else
      flash[:error] = "#{user.errors.full_messages.to_sentence}"
      redirect_to register_url
    end
  end

  private

  def user_creation_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
