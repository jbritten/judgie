require File.dirname(__FILE__) + '/../test_helper'

class StatsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:stats)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_stat
    assert_difference('Stat.count') do
      post :create, :stat => { }
    end

    assert_redirected_to stat_path(assigns(:stat))
  end

  def test_should_show_stat
    get :show, :id => stats(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => stats(:one).id
    assert_response :success
  end

  def test_should_update_stat
    put :update, :id => stats(:one).id, :stat => { }
    assert_redirected_to stat_path(assigns(:stat))
  end

  def test_should_destroy_stat
    assert_difference('Stat.count', -1) do
      delete :destroy, :id => stats(:one).id
    end

    assert_redirected_to stats_path
  end
end
