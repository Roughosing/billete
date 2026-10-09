require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  test "guests can browse the marketplace" do
    get root_path
    assert_response :success
    assert_select "h1", text: "Upcoming events"
  end

  test "guests can view an event" do
    event = Organization.create!(name: "Venue").events.create!(
      title: "Opening night",
      description: "Doors at seven",
      location: "Dublin",
      starts_at: 1.day.from_now,
      ends_at: 2.days.from_now,
      capacity: 100,
      price_cents: 1500
    )

    get event_path(event)

    assert_response :success
    assert_select "h1", text: "Opening night"
    assert_select "dd", text: "Dublin"
  end
end
