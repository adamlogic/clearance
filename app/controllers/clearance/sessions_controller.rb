class Clearance::SessionsController < ApplicationController
  unloadable

  skip_before_filter :authenticate
  protect_from_forgery :except => :create
  filter_parameter_logging :password

  def new
    render :template => 'sessions/new'
  end

  def create
    @user = ::User.authenticate(params[:session][:email],
                              params[:session][:password])
    if @user.nil?
      flash.now[NOTICE_FLASH] = "Bad email or password."
      render :template => 'sessions/new', :status => :unauthorized
    else
      if @user.email_confirmed?
        remember(@user) if remember?
        sign_user_in(@user)
        flash[SUCCESS_FLASH] = "Signed in successfully."
        redirect_back_or url_after_create
      else
        ::ClearanceMailer.deliver_confirmation(@user)
        deny_access("User has not confirmed email. Confirmation email will be resent.")
      end
    end
  end

  def destroy
    forget(current_user)
    reset_session
    flash[NOTICE_FLASH] = "You have been signed out."
    redirect_to url_after_destroy
  end

  private

  def remember?
    params[:session] && params[:session][:remember_me] == "1"
  end

  def remember(user)
    user.remember_me!
    cookies[:remember_token] = { :value   => user.token,
                                 :expires => user.token_expires_at }
  end

  def forget(user)
    user.forget_me! if user
    cookies.delete :remember_token
  end

  def url_after_create
    root_url
  end

  def url_after_destroy
    new_session_url
  end

end
