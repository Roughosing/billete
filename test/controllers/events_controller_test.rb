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
      ends_at: 2.days.from_now
    )

    get event_path(event)

    assert_response :success
    assert_select "h1", text: "Opening night"
    assert_select "dd", text: "Dublin"
  end

  test "the marketplace lists events until they end" do
    organization = Organization.create!(name: "Venue")
    in_progress = create_event(organization, "In progress", starts_at: 1.hour.ago, ends_at: 1.hour.from_now)
    upcoming = create_event(organization, "Upcoming", starts_at: 1.day.from_now, ends_at: 2.days.from_now)
    create_event(organization, "Finished", starts_at: 2.days.ago, ends_at: 1.day.ago)

    get root_path

    assert_select "h2.event-card__title", text: in_progress.title
    assert_select "h2.event-card__title", text: upcoming.title
    assert_select "h2.event-card__title", text: "Finished", count: 0
  end

  private

  def create_event(organization, title, starts_at:, ends_at:)
    organization.events.create!(title: title, description: "d", location: "Dublin", starts_at: starts_at, ends_at: ends_at)
  end
end
