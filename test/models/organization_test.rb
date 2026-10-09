require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "strips the name" do
    organization = Organization.create!(name: "  North Gate  ")

    assert_equal "North Gate", organization.reload.name
  end

  test "requires a name" do
    organization = Organization.new(name: "   ")

    assert_not organization.valid?
    assert_includes organization.errors[:name], "can't be blank"
  end
end
