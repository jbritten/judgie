class PasswordsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :login_required, :except => [:create]

  # Don't write passwords, activation codes, or email addresses as plain text to the log files 
  filter_parameter_logging :old_password, :password, :password_confirmation

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create], :redirect_to => { :controller => :site }
  verify :method => :put, :only => [:update], :redirect_to => { :controller => :site }

  # POST /passwords
  # Forgot password
  def create
    respond_to do |format|

      if user = User.find_by_email_and_login(params[:email], params[:login])
        @new_password = random_password
        user.password = user.password_confirmation =  @new_password
        user.save_without_validation
        UserNotifier.deliver_new_password(user, @new_password)

        # format.html { 
        #   flash[:notice] = "We sent a new password to #{params[:email]}"
        #   redirect_to signin_path 
        # }
        format.js
      else
        flash[:sidebar] =  "We can't find that account.  Try again."

        # format.html { render :action => "new" }
        format.js
      end
    end
  end  
  
  # GET /users/1/password/edit
  # Changing password
  def edit
    @user = current_user
  end
  
  # PUT /users/1/password
  # Changing password
  def update
    @user = current_user

    old_password = params[:old_password]

    @user.attributes = params[:user]
    
    respond_to do |format|
      if @user.authenticated?(old_password) && @user.save
        format.html { redirect_to user_path(@user) }
      else
        format.html { render :action => 'edit' }
      end
    end
  end

  protected 

  def random_password( len = 20 )
    chars = (("a".."z").to_a + ("1".."9").to_a )- %w(i o 0 1 l 0)
    newpass = Array.new(len, '').collect{chars[rand(chars.size)]}.join
  end

end
