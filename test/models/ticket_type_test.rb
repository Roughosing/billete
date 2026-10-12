require "test_helper"

class TicketTypeTest < ActiveSupport::TestCase
  setup do
    @event = Organization.create!(name: "North Gate").events.create!(
      title: "Opening night",
      description: "Doors at seven",
      location: "Dublin",
      starts_at: 2.days.from_now,
      ends_at: 3.days.from_now
    )
  end

  test "requires a name, a non-negative price, and a positive quantity" do
    ticket_type = @event.ticket_types.new(name: "", price: -1, quantity: 0)

    assert_not ticket_type.valid?
    assert_includes ticket_type.errors[:name], "can't be blank"
    assert_includes ticket_type.errors[:price], "must be greater than or equal to 0"
    assert_includes ticket_type.errors[:quantity], "must be greater than 0"
  end

  test "sale window must end after it starts" do
    ticket_type = @event.ticket_types.new(
      name: "Early bird",
      price: 10,
      quantity: 20,
      sales_starts_at: 2.days.from_now,
      sales_ends_at: 1.day.from_now
    )

    assert_not ticket_type.valid?
    assert_includes ticket_type.errors[:sales_ends_at], "must be after the start"
  end

  test "on sale types are those whose window contains now" do
    open = @event.ticket_types.create!(name: "General admission", price: 10, quantity: 10)
    upcoming = @event.ticket_types.create!(
      name: "Early bird",
      price: 8,
      quantity: 10,
      sales_starts_at: 1.day.from_now,
      sales_ends_at: 2.days.from_now
    )
    closed = @event.ticket_types.create!(
      name: "Last release",
      price: 12,
      quantity: 10,
      sales_starts_at: 2.days.ago,
      sales_ends_at: 1.day.ago
    )

    on_sale = TicketType.on_sale

    assert_includes on_sale, open
    assert_not_includes on_sale, upcoming
    assert_not_includes on_sale, closed
  end

  test "available types are on sale and still have quantity left" do
    open = @event.ticket_types.create!(name: "General admission", price: 10, quantity: 1)
    sold_out = @event.ticket_types.create!(name: "VIP", price: 25, quantity: 1)
    sold_out.tickets.create!(user: users(:one))
    closed = @event.ticket_types.create!(
      name: "Last release",
      price: 12,
      quantity: 10,
      sales_ends_at: 1.hour.ago
    )

    available = TicketType.available

    assert_includes available, open
    assert_not_includes available, sold_out
    assert_not_includes available, closed
    assert_equal 0, sold_out.remaining
  end

  test "quantity cannot drop below tickets already issued" do
    ticket_type = @event.ticket_types.create!(name: "General admission", price: 10, quantity: 2)
    ticket_type.tickets.create!(user: users(:one))
    ticket_type.tickets.create!(user: users(:two))

    assert_not ticket_type.update(quantity: 1)
    assert_includes ticket_type.errors[:quantity], "must cover tickets already issued"
  end

  test "lists types by position" do
    second = @event.ticket_types.create!(name: "VIP", price: 25, quantity: 5, position: 1)
    first = @event.ticket_types.create!(name: "General admission", price: 10, quantity: 5, position: 0)

    assert_equal [ first, second ], @event.ticket_types.to_a
  end
end
