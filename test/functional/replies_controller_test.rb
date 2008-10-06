require File.dirname(__FILE__) + '/../test_helper'

class RepliesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:replies)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_reply
    assert_difference('Reply.count') do
      post :create, :reply => { }
    end

    assert_redirected_to reply_path(assigns(:reply))
  end

  def test_should_show_reply
    get :show, :id => replies(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => replies(:one).id
    assert_response :success
  end

  def test_should_update_reply
    put :update, :id => replies(:one).id, :reply => { }
    assert_redirected_to reply_path(assigns(:reply))
  end

  def test_should_destroy_reply
    assert_difference('Reply.count', -1) do
      delete :destroy, :id => replies(:one).id
    end

    assert_redirected_to replies_path
  end
end
