require File.dirname(__FILE__) + '/../test_helper'

class BetaInvitationsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:beta_invitations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_beta_invitation
    assert_difference('BetaInvitation.count') do
      post :create, :beta_invitation => { }
    end

    assert_redirected_to beta_invitation_path(assigns(:beta_invitation))
  end

  def test_should_show_beta_invitation
    get :show, :id => beta_invitations(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => beta_invitations(:one).id
    assert_response :success
  end

  def test_should_update_beta_invitation
    put :update, :id => beta_invitations(:one).id, :beta_invitation => { }
    assert_redirected_to beta_invitation_path(assigns(:beta_invitation))
  end

  def test_should_destroy_beta_invitation
    assert_difference('BetaInvitation.count', -1) do
      delete :destroy, :id => beta_invitations(:one).id
    end

    assert_redirected_to beta_invitations_path
  end
end
