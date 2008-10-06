class SiteController < ApplicationController
  caches_page :terms_of_service, :privacy_policy, :about, :custom404
  before_filter :login_from_cookie
  
  def index
    # If a user is logged in, only show questions they haven't answered
    
    if logged_in?
      @questions = Question.paginate(:page => params[:page], 
                                      :per_page => 20,
                                      :conditions => ["NOT EXISTS (SELECT id FROM replies WHERE (replies.user_id = ?) AND (replies.question_id = questions.id))", current_user.id],
                                      :include => :user,
                                      :order => 'questions.created_at DESC')
    else
      @questions = Question.paginate(:page => params[:page], 
  		                               :per_page => 20,
  		                               :include => :user,
  		                               :order => 'questions.created_at DESC')
    end

    respond_to do |format|
      format.html
    end
  end

  def terms_of_service
    respond_to do |format|
      format.html
    end
  end
  
  def privacy_policy
    respond_to do |format|
      format.html
    end
  end
  
  def about
    respond_to do |format|
      format.html
    end
  end
  
  def custom404
    render :partial => "custom404", :layout => "application", :status => "404"
  end
end
