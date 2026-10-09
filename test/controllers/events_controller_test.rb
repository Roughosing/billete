require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  test "guests can browse the marketplace" do
    get root_path
    assert_response :success
    assert_select "h1", text: "Upcoming events"
  end
end
