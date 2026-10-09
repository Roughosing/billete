require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "guests are asked to sign in" do
    get organization_path
    assert_redirected_to new_session_path
  end

  test "a user without an organization is offered the form" do
    sign_in_as @user

    get organization_path

    assert_redirected_to new_organization_path
  end

  test "new organization form" do
    sign_in_as @user

    get new_organization_path

    assert_response :success
    assert_select "h1", "Create your organization"
  end

  test "create makes an admin membership and opens the admin page" do
    sign_in_as @user

    assert_difference -> { Organization.count } => 1, -> { Membership.count } => 1 do
      post organization_path, params: { organization: { name: " North Gate " } }
    end

    assert_redirected_to organization_path
    follow_redirect!
    assert_select "h1", "North Gate"
    assert @user.reload.membership.admin?
    assert_equal "North Gate", @user.organization.name
  end

  test "create rejects a blank name and leaves no membership" do
    sign_in_as @user

    assert_no_difference [ -> { Organization.count }, -> { Membership.count } ] do
      post organization_path, params: { organization: { name: "  " } }
    end

    assert_response :unprocessable_entity
    assert_nil @user.reload.membership
  end

  test "a member opens the admin page" do
    join_organization("North Gate")
    sign_in_as @user

    get organization_path

    assert_response :success
    assert_select "h1", "North Gate"
    assert_select "a[aria-current=page]", text: "Events"
  end

  test "a member skips the new form" do
    join_organization("North Gate")
    sign_in_as @user

    get new_organization_path

    assert_redirected_to organization_path
  end

  test "update renames the organization" do
    organization = join_organization("North Gate")
    sign_in_as @user

    patch organization_path, params: { organization: { name: "South Gate" } }

    assert_redirected_to edit_organization_path
    assert_equal "South Gate", organization.reload.name
  end

  test "the account menu sends a new organizer to the form" do
    sign_in_as @user

    get root_path

    assert_select "summary", text: "One Example"
    assert_select "a[href='#{new_organization_path}']", text: "Manage my events"
    assert_select "a[href='#{settings_profile_path}']", text: "Account settings"
  end

  test "the account menu sends a member to the admin page" do
    join_organization("North Gate")
    sign_in_as @user

    get root_path

    assert_select "a[href='#{organization_path}']", text: "Manage my events"
  end

  private

  def join_organization(name)
    Organization.create!(name: name).tap do |organization|
      organization.memberships.create!(user: @user, role: :admin)
    end
  end
end
