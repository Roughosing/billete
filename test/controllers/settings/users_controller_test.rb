require "test_helper"

class Settings::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as @user
  end

  test "show" do
    get settings_user_path
    assert_response :success
  end

  test "destroy deletes the account and ends the session" do
    assert_difference -> { User.count }, -1 do
      delete settings_user_path
    end

    assert_redirected_to root_path
    assert_empty cookies[:session_id]
    assert_nil User.find_by(id: @user.id)

    follow_redirect!
    assert_select "p.flash", text: /deleted/
  end
end
