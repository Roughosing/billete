require "test_helper"

class TicketTest < ActiveSupport::TestCase
  setup do
    @organization = Organization.create!(name: "North Gate")
    @event = @organization.events.create!(
      title: "Opening night",
      description: "Doors at seven",
      location: "Dublin",
      starts_at: 2.days.from_now,
      ends_at: 3.days.from_now
    )
    @ticket_type = @event.ticket_types.create!(name: "General admission", price: 10, quantity: 2)
  end

  test "copies price, currency, code, and issue time from the type and event" do
    ticket = @ticket_type.tickets.create!(user: users(:one))

    assert_equal @event, ticket.event
    assert_equal 10, ticket.price
    assert_equal "EUR", ticket.currency
    assert_predicate ticket.code, :present?
    assert_predicate ticket.issued_at, :present?
    assert_predicate ticket, :confirmed?

    @ticket_type.update!(price: 15)
    @event.update!(currency: "USD")

    ticket.reload
    assert_equal 10, ticket.price
    assert_equal "EUR", ticket.currency
  end

  test "rejects a ticket type from another event" do
    other_event = @organization.events.create!(
      title: "Matinee",
      description: "Afternoon show",
      location: "Dublin",
      starts_at: 4.days.from_now,
      ends_at: 5.days.from_now
    )
    ticket = Ticket.new(user: users(:one), event: other_event, ticket_type: @ticket_type, price: 10)

    assert_not ticket.valid?
    assert_includes ticket.errors[:ticket_type], "must belong to the event"
  end

  test "rejects a confirmed ticket once the type is sold out" do
    @ticket_type.tickets.create!(user: users(:one))
    @ticket_type.tickets.create!(user: users(:two))
    extra = @ticket_type.tickets.new(user: users(:one))

    assert_not extra.valid?
    assert_includes extra.errors[:ticket_type], "is sold out"
  end

  test "a cancelled ticket does not take a place" do
    @ticket_type.tickets.create!(user: users(:one), status: :cancelled)
    ticket = @ticket_type.tickets.create!(user: users(:two))

    assert_predicate ticket, :confirmed?
    assert_equal 1, @ticket_type.remaining
  end

  test "a cancelled ticket cannot be reconfirmed once the type is full" do
    cancelled = @ticket_type.tickets.create!(user: users(:one), status: :cancelled)
    @ticket_type.tickets.create!(user: users(:one))
    @ticket_type.tickets.create!(user: users(:two))

    assert_not cancelled.update(status: :confirmed)
    assert_includes cancelled.errors[:ticket_type], "is sold out"
    assert_equal 0, @ticket_type.remaining
  end

  test "issue! creates a confirmed ticket and raises when sold out" do
    first = @ticket_type.issue!(user: users(:one))
    @ticket_type.issue!(user: users(:two))

    assert_predicate first, :confirmed?
    assert_equal 0, @ticket_type.remaining

    error = assert_raises(ActiveRecord::RecordInvalid) { @ticket_type.issue!(user: users(:one)) }
    assert_includes error.record.errors[:ticket_type], "is sold out"
  end

  test "upcoming tickets are confirmed admissions to events that have not ended" do
    upcoming = @ticket_type.tickets.create!(user: users(:one))
    in_progress_type = create_type_for_event(starts_at: 1.hour.ago, ends_at: 1.hour.from_now)
    in_progress = in_progress_type.tickets.create!(user: users(:one))
    past_type = create_type_for_event(starts_at: 2.days.ago, ends_at: 1.day.ago)
    past = past_type.tickets.create!(user: users(:one))
    cancelled = @ticket_type.tickets.create!(user: users(:two), status: :cancelled)

    assert_equal [ in_progress, upcoming ], users(:one).tickets.upcoming
    assert_equal [ past ], users(:one).tickets.past
    assert_not_includes users(:two).tickets.upcoming, cancelled
  end

  test "deleting a user removes their tickets and keeps the event" do
    @ticket_type.tickets.create!(user: users(:one))

    assert_difference -> { Ticket.count }, -1 do
      assert_no_difference -> { Event.count } do
        users(:one).destroy!
      end
    end
  end

  private

  def create_type_for_event(starts_at:, ends_at:)
    event = @organization.events.create!(
      title: "Show #{starts_at.to_i}",
      description: "Doors at seven",
      location: "Dublin",
      starts_at: starts_at,
      ends_at: ends_at
    )
    event.ticket_types.create!(name: "General admission", price: 10, quantity: 5)
  end
end
