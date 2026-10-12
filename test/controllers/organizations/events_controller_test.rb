require "test_helper"

class Organizations::EventsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "guests are asked to sign in" do
    get new_organization_event_path
    assert_redirected_to new_session_path
  end

  test "a user without an organization is sent to create one" do
    sign_in_as @user

    get new_organization_event_path
    assert_redirected_to new_organization_path

    assert_no_difference -> { Event.count } do
      post organization_events_path, params: { event: valid_event_params }
    end
    assert_redirected_to new_organization_path
  end

  test "the form offers a general admission ticket type" do
    join_organization
    sign_in_as @user

    get new_organization_event_path

    assert_response :success
    assert_select "input[name='event[ticket_types_attributes][0][name]'][value='General admission']"
    assert_select "input[name='event[ticket_types_attributes][0][price]'][step='0.01']"
  end

  test "create saves the event with its ticket type and a decimal price" do
    organization = join_organization
    sign_in_as @user

    assert_difference -> { Event.count } => 1, -> { TicketType.count } => 1 do
      post organization_events_path, params: { event: valid_event_params }
    end

    assert_redirected_to organization_path
    event = organization.events.last
    ticket_type = event.ticket_types.first
    assert_equal "General admission", ticket_type.name
    assert_equal BigDecimal("12.50"), ticket_type.price
    assert_equal 100, ticket_type.quantity
  end

  test "staff can create events" do
    join_organization(role: :staff)
    sign_in_as @user

    assert_difference -> { Event.count }, 1 do
      post organization_events_path, params: { event: valid_event_params }
    end
  end

  test "create with an invalid ticket type saves nothing and re-renders" do
    join_organization
    sign_in_as @user

    assert_no_difference [ -> { Event.count }, -> { TicketType.count } ] do
      post organization_events_path, params: {
        event: valid_event_params.deep_merge(ticket_types_attributes: { "0" => { quantity: 0 } })
      }
    end

    assert_response :unprocessable_entity
    assert_select "div", text: /quantity/i
  end

  private

  def valid_event_params
    {
      title: "Opening night",
      description: "Doors at seven",
      location: "Dublin",
      starts_at: 1.day.from_now.iso8601,
      ends_at: 2.days.from_now.iso8601,
      ticket_types_attributes: { "0" => { name: "General admission", price: "12.50", quantity: 100 } }
    }
  end

  def join_organization(role: :admin)
    Organization.create!(name: "North Gate").tap do |organization|
      organization.memberships.create!(user: @user, role: role)
    end
  end
end
