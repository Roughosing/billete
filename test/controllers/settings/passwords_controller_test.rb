require "test_helper"

class Settings::PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as @user
  end

  test "show" do
    get settings_password_path
    assert_response :success
  end

  test "update changes the password when the current password matches" do
    assert_changes -> { @user.reload.password_digest } do
      patch settings_password_path, params: {
        user: { password_challenge: "password", password: "new-password", password_confirmation: "new-password" }
      }
    end

    assert_redirected_to settings_profile_path
    assert @user.reload.authenticate("new-password")
  end

  test "update rejects a wrong current password" do
    assert_no_changes -> { @user.reload.password_digest } do
      patch settings_password_path, params: {
        user: { password_challenge: "wrong", password: "new-password", password_confirmation: "new-password" }
      }
    end

    assert_response :unprocessable_entity
  end

  test "update rejects a missing current password" do
    assert_no_changes -> { @user.reload.password_digest } do
      patch settings_password_path, params: {
        user: { password: "new-password", password_confirmation: "new-password" }
      }
    end

    assert_response :unprocessable_entity
  end
end
