require "test_helper"

class Settings::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as @user
  end

  test "show" do
    get settings_email_path
    assert_response :success
  end

  test "update stores the new address and sends a confirmation" do
    assert_enqueued_email_with UserMailer, :email_confirmation, params: { user: @user } do
      patch settings_email_path, params: {
        user: { unconfirmed_email: "next@example.com", password_challenge: "password" }
      }
    end

    assert_redirected_to settings_email_path
    assert_equal "next@example.com", @user.reload.unconfirmed_email
    assert_equal "one@example.com", @user.email_address
  end

  test "update rejects a wrong current password" do
    assert_no_enqueued_emails do
      patch settings_email_path, params: {
        user: { unconfirmed_email: "next@example.com", password_challenge: "wrong" }
      }
    end

    assert_response :unprocessable_entity
    assert_nil @user.reload.unconfirmed_email
  end
end
