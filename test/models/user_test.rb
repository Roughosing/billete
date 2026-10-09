require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "confirm_email promotes the unconfirmed address" do
    user = users(:one)
    user.update!(unconfirmed_email: "next@example.com")

    assert user.confirm_email

    user.reload
    assert_equal "next@example.com", user.email_address
    assert_nil user.unconfirmed_email
  end

  test "email confirmation token is tied to the unconfirmed address" do
    user = users(:one)
    user.update!(unconfirmed_email: "next@example.com")
    token = user.generate_token_for(:email_confirmation)

    user.update!(unconfirmed_email: "other@example.com")

    assert_nil User.find_by_token_for(:email_confirmation, token)
  end
end
