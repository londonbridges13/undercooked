require 'test_helper'

class AutoPublishingsControllerTest < ActionController::TestCase
  setup do
    @auto_publishing = auto_publishings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:auto_publishings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create auto_publishing" do
    assert_difference('AutoPublishing.count') do
      post :create, auto_publishing: { reasons: @auto_publishing.reasons }
    end

    assert_redirected_to auto_publishing_path(assigns(:auto_publishing))
  end

  test "should show auto_publishing" do
    get :show, id: @auto_publishing
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @auto_publishing
    assert_response :success
  end

  test "should update auto_publishing" do
    patch :update, id: @auto_publishing, auto_publishing: { reasons: @auto_publishing.reasons }
    assert_redirected_to auto_publishing_path(assigns(:auto_publishing))
  end

  test "should destroy auto_publishing" do
    assert_difference('AutoPublishing.count', -1) do
      delete :destroy, id: @auto_publishing
    end

    assert_redirected_to auto_publishings_path
  end
end
