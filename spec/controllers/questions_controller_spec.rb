require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionsController, " handling GET /questions/new" do
  before do
    signin
  end
  
  def do_get
    get :new
  end
  
  it "should render new question form" do
    do_get
    response.should render_template('new')
  end
  
end

describe QuestionsController, " handling POST /questions" do
  before do
    signin
  end
  
  def do_post
    post :create
  end
  
  it "should redirect to home on success" do
    pending
  end

  it "should render new question form on failure" do
    pending
  end
  
end

describe QuestionsController, "signin enforcer" do
  include SigninRequiredHelper
  
  before(:each) do
    controller.stub!(:current_user).and_return(false)
  end

  it "should require login for all actions" do
    controller_actions_should_fail_if_not_logged_in(:questions)
  end
end