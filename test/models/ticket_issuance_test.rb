require "test_helper"

# Exercises TicketType#issue! across real concurrent database connections.
# Transactional tests would hide the race (every thread would share one
# uncommitted transaction), so this class commits its data and cleans up.
class TicketIssuanceTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @organization = Organization.create!(name: "Race track")
    @event = @organization.events.create!(
      title: "Final place",
      description: "One left",
      location: "Dublin",
      starts_at: 2.days.from_now,
      ends_at: 3.days.from_now
    )
    @ticket_type = @event.ticket_types.create!(name: "General admission", price: 10, quantity: 1)
    @buyers = [ users(:one), users(:two) ]
  end

  teardown do
    @organization.destroy!
  end

  test "two buyers racing for the last place get exactly one ticket" do
    ready = Queue.new
    go = Queue.new

    outcomes = @buyers.map do |buyer|
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          ticket_type = TicketType.find(@ticket_type.id)
          ready << true
          go.pop
          begin
            ticket_type.issue!(user: buyer)
            :issued
          rescue ActiveRecord::RecordInvalid
            :sold_out
          end
        end
      end
    end

    @buyers.size.times { ready.pop }
    @buyers.size.times { go << true }

    assert_equal %i[ issued sold_out ], outcomes.map(&:value).sort
    assert_equal 1, @ticket_type.tickets.confirmed.count
    assert_equal 0, @ticket_type.reload.remaining
  end
end
