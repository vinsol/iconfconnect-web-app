class UserSessionController < ApplicationController

  def create
    #FIXED: while creating user you have used create! which will raise exception so you should handle the exception. or don't use bang and handle the case 
    auth = request.env["omniauth.auth"]
    user = User.where(:provider => auth['provider'],
                      :uid => auth['uid'].to_s).first || User.create_with_omniauth(auth)
    if user
      reset_session
      session[:user_id] = user.id
      redirect_to root_url, :notice => 'Signed in!'
    else
      redirect_to root_url, notice: 'Authentication error'
    end    
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'Signed out!'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end
end