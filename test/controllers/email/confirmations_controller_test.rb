require "test_helper"

class Email::ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  test "a valid token promotes the unconfirmed address" do
    user = users(:one)
    user.update!(unconfirmed_email: "next@example.com")

    get email_confirmation_path(user.generate_token_for(:email_confirmation))

    assert_redirected_to root_path
    assert_equal "next@example.com", user.reload.email_address
    assert_nil user.unconfirmed_email

    follow_redirect!
    assert_select "p.flash-notice", text: /confirmed/
  end

  test "an invalid token leaves the address unchanged" do
    user = users(:one)

    get email_confirmation_path("not-a-token")

    assert_redirected_to root_path
    assert_equal "one@example.com", user.reload.email_address

    follow_redirect!
    assert_select "p.flash-alert", text: /Invalid token/
  end
end
