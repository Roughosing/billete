require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  setup do
    @organization = Organization.create!(name: "North Gate")
    @other = Organization.create!(name: "South Gate")
  end

  test "a user reaches one organization through a membership" do
    membership = users(:one).create_membership!(organization: @organization, role: :admin)

    assert membership.admin?
    assert_equal @organization, users(:one).organization
    assert_includes @organization.users, users(:one)
  end

  test "role is staff by default and rejects any other value" do
    membership = users(:one).create_membership!(organization: @organization)

    assert membership.staff?

    rejected = Membership.new(user: users(:two), organization: @organization, role: "customer")

    assert_not rejected.valid?
    assert_includes rejected.errors[:role], "is not included in the list"
  end

  test "a user cannot belong to a second organization" do
    users(:one).create_membership!(organization: @organization, role: :admin)
    duplicate = Membership.new(user: users(:one), organization: @other, role: :staff)

    assert_not duplicate.valid?

    assert_raises ActiveRecord::RecordNotUnique do
      Membership.transaction(requires_new: true) do
        duplicate.save!(validate: false)
      end
    end
  end

  test "deleting a user removes the membership and keeps the organization" do
    users(:one).create_membership!(organization: @organization, role: :staff)

    assert_difference -> { Membership.count }, -1 do
      assert_no_difference -> { Organization.count } do
        users(:one).destroy!
      end
    end

    assert Organization.exists?(@organization.id)
  end
end
