# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  before_filter :login_from_cookie

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create], :redirect_to => { :controller => :site }
  verify :method => :delete, :only => [:destroy], :redirect_to => { :controller => :site }
  
  # render new.rhtml
  def new
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])

    respond_to do |format|
      if logged_in?
        if params[:remember_me] == "1"
          self.current_user.remember_me
          cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        end
        format.html { redirect_back_or_default('/') }
      else
        format.html { 
          flash[:signin_message] =  "Sign in failed.  Try again."
          redirect_to home_path }
      end
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    
    respond_to do |format|
      format.html { redirect_to home_path }
    end
  end
end
