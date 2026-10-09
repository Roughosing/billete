require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "email_confirmation" do
    user = users(:one)
    user.update!(unconfirmed_email: "next@example.com")

    mail = UserMailer.with(user: user).email_confirmation

    assert_equal "Email confirmation", mail.subject
    assert_equal [ "next@example.com" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match %r{/email/confirmations/}, mail.body.encoded
  end
end
