class SessionsController < ApplicationController

  def new
    if current_user
      redirect_to root_url
    else
      render 'sessions/new'
    end
  end

  def create
    user = User.find_by(email: session_creation_params[:email].downcase)
    if user && user.authenticate(session_creation_params[:password])
      session[:user_id] = user.id
      redirect_to root_url
    else
      flash.now[:error] = "Invalid email or password"
      render 'sessions/new'
    end
  end

  def destroy
    session.destroy
    redirect_to root_url
  end

  private

  def session_creation_params
    params.require(:user).permit(:email, :password)
  end
end
