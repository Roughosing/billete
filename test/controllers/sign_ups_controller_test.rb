require "test_helper"

class SignUpsControllerTest < ActionDispatch::IntegrationTest
  test "show" do
    get sign_up_path
    assert_response :success
  end

  test "create signs the user in" do
    assert_difference -> { User.count }, 1 do
      post sign_up_path, params: {
        user: {
          first_name: "Ada",
          last_name: "Lovelace",
          email_address: " Ada@Example.com ",
          password: "secretsecret",
          password_confirmation: "secretsecret"
        }
      }
    end

    assert_redirected_to root_path
    assert cookies[:session_id]
    assert_equal "ada@example.com", User.find_by!(first_name: "Ada").email_address

    follow_redirect!
    assert_select "summary", text: "Ada Lovelace"
  end

  test "create with invalid details renders the form" do
    assert_no_difference -> { User.count } do
      post sign_up_path, params: {
        user: {
          first_name: "",
          last_name: "Lovelace",
          email_address: "ada@example.com",
          password: "secretsecret",
          password_confirmation: "nope"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "a signed in user is sent back to the marketplace" do
    sign_in_as users(:one)

    get sign_up_path

    assert_redirected_to root_path
  end
end
