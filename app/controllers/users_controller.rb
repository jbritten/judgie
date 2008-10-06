class UsersController < ApplicationController
  before_filter :login_from_cookie
  before_filter :login_required, :only => [:edit, :update]

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create], :redirect_to => { :controller => :site }
  verify :method => :put, :only => [:update], :redirect_to => { :controller => :site }
  
  # GET /question/1
  # Show user's questions
  def show
    @user = User.find_by_login(params[:id])

    @questions = @user.questions.paginate(:page => params[:page], :per_page => 10, :conditions => "NOT anonymous")

    respond_to do |format|
      format.html # show.html.erb
    end
  end  

  # GET /users/new
  def new
  end

  # POST /users
  # Signup a new user
  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session

    @user = User.new(params[:user])
    @user.gender = params[:user][:gender].to_i
    @user.birthdate = Date.new(params[:date]['birth_year'].to_i, params[:date]['birth_month'].to_i, params[:date]['birth_day'].to_i)
    
    # Validate the beta invitation code.
    if REQUIRE_INVITE_TO_SIGNUP
      beta_verify = Digest::MD5.hexdigest("asecretkeygoeshere"+params[:user][:email])
      unless params[:invitation_code] == beta_verify
        flash[:notice] = "The invitation code you used is not valid."
        render :action => 'new'
        return
      end
    end
    
    if verify_recaptcha(@user) && @user.save
      self.current_user = @user

      # Create the user's stats table
      stat = Stat.new(:user_id => @user.id)

      if stat.save
        # Send the new user welcome email
        UserNotifier.deliver_signup_notification(@user)
        
        redirect_to home_path
      else
        @user.destroy
        stat.destroy unless stat.nil?
        flash[:error] = "Your account couldn't be created"
        render :action => 'new'
      end
    else
      render :action => 'new'
    end
  end

  # GET /users/1/edit
  # Changing username, email, or profile
  def edit
    # @user = User.find(params[:id])
    @user = current_user
  end
  
  # PUT /users/1
  # Changing username, email, or profile
  def update
    # @user = User.find(params[:id])
    @user = current_user
    
    @user.attributes = params[:user]
    @user.gender = params[:user][:gender].to_i
    @user.birthdate = Date.new(params[:date]['birth_year'].to_i, params[:date]['birth_month'].to_i, params[:date]['birth_day'].to_i)
    
    respond_to do |format|
      if @user.save
        format.html { redirect_to home_path }
      else
        format.html { render :action => 'edit' }
      end
    end
  end
  
end
