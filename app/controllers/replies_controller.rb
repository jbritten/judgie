class RepliesController < ApplicationController
  before_filter :login_from_cookie
  before_filter :login_required

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create], :redirect_to => { :controller => :site }
  verify :method => :put, :only => [:update], :redirect_to => { :controller => :site }
  
  # GET /users/username/replies
  def index
    @user = User.find_by_login(params[:user_id])

    # Don't let other user's peek at this user's replies
    redirect_to home_path and return if @user != current_user
    
    @questions = @user.replied_questions.paginate(:page => params[:page], 
		                                              :per_page => 20,
		                                              :order => 'replies.updated_at DESC')

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  # POST /questions/replies
  def create
    @reply = Reply.new(params[:reply])
    @reply.question_id = params[:question_id]
    @reply.user = current_user
    
    respond_to do |format|
      if @reply.save
        @question = Question.find(params[:question_id])
        format.html { redirect_to home_path }
        format.js
      else
        format.html { redirect_to home_path }
      end
    end
  end

  # PUT /questions/replies/1
  def update
    @reply = Reply.find(params[:id], :include => :question)
    @question = @reply.question
    
    was_yes = @reply.yes?
    now_yes = params[:reply][:yes].to_i == Reply::Response::Yes
    
    respond_to do |format|
      if @reply.update_attributes(params[:reply])
        # Make sure we keep the question's response cache updated
        if was_yes and not now_yes
          @question.increment(:no_count)
          @question.decrement(:yes_count)
          @question.save
        elsif not was_yes and now_yes
          @question.increment(:yes_count)
          @question.decrement(:no_count)
          @question.save
        end
        
        format.html { redirect_to home_path }
        format.js
      else
        format.html { redirect_to home_path }
      end
    end
  end

end
