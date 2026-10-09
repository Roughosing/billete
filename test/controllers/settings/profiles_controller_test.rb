require "test_helper"

class Settings::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "guests are asked to sign in" do
    get settings_profile_path
    assert_redirected_to new_session_path
  end

  test "show" do
    sign_in_as @user
    get settings_profile_path
    assert_response :success
    assert_select "a[aria-current=page]", text: "Profile"
  end

  test "settings root opens the profile" do
    sign_in_as @user
    get settings_root_path
    assert_redirected_to settings_profile_path
  end

  test "update changes the name" do
    sign_in_as @user

    patch settings_profile_path, params: { user: { first_name: "Updated", last_name: "Name" } }

    assert_redirected_to settings_profile_path
    assert_equal "Updated Name", @user.reload.full_name
  end

  test "update rejects a blank name" do
    sign_in_as @user

    patch settings_profile_path, params: { user: { first_name: "", last_name: "Name" } }

    assert_response :unprocessable_entity
    assert_equal "One", @user.reload.first_name
  end
end
