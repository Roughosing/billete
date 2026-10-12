require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "email address must be unique and well formed" do
    taken = User.new(first_name: "A", last_name: "B", email_address: "ONE@example.com", password: "secretsecret")
    assert_not taken.valid?
    assert_includes taken.errors[:email_address], "has already been taken"

    malformed = User.new(first_name: "A", last_name: "B", email_address: "nope", password: "secretsecret")
    assert_not malformed.valid?
    assert_includes malformed.errors[:email_address], "is invalid"
  end

  test "confirm_email fails cleanly if the address was taken in the meantime" do
    user = users(:one)
    user.update!(unconfirmed_email: "next@example.com")
    User.create!(first_name: "A", last_name: "B", email_address: "next@example.com", password: "secretsecret")

    assert_not user.confirm_email
    assert_equal "one@example.com", user.reload.email_address
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
