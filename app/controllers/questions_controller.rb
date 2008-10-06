class QuestionsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :login_required, :except => [:search]

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [:create], :redirect_to => { :controller => :site }

  # GET /questions/:id
  def show
    @question = Question.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  # GET /questions/new
  def new
    @question = Question.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /questions
  def create
    @question = Question.new(params[:question])
    @question.user = current_user
    
    respond_to do |format|
      if @question.save
        format.html { redirect_to home_path }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # GET /questions/search
  def search
    @query = params[:query]
    @questions = Ultrasphinx::Search.new(:query => @query, :page => params[:page] || 1, :per_page => 20)
    @questions.run
    @questions.results
    
    respond_to do |format|
      format.html # search.html.erb
    end
  end
  
end
