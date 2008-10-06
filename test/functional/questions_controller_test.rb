require File.dirname(__FILE__) + '/../test_helper'

class QuestionsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:questions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_question
    assert_difference('Question.count') do
      post :create, :question => { }
    end

    assert_redirected_to question_path(assigns(:question))
  end

  def test_should_show_question
    get :show, :id => questions(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => questions(:one).id
    assert_response :success
  end

  def test_should_update_question
    put :update, :id => questions(:one).id, :question => { }
    assert_redirected_to question_path(assigns(:question))
  end

  def test_should_destroy_question
    assert_difference('Question.count', -1) do
      delete :destroy, :id => questions(:one).id
    end

    assert_redirected_to questions_path
  end
end
