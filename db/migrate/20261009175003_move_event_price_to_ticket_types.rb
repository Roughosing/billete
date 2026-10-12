class MoveEventPriceToTicketTypes < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      INSERT INTO ticket_types (event_id, name, price, quantity, position, created_at, updated_at)
      SELECT id, 'General admission', price_cents / 100.0, capacity, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM events
    SQL

    remove_check_constraint :events, name: "events_price_cents_non_negative"
    remove_column :events, :price_cents
  end

  def down
    add_column :events, :price_cents, :integer

    execute <<~SQL.squish
      UPDATE events
      SET price_cents = (
        SELECT ROUND(price * 100)::integer
        FROM ticket_types
        WHERE ticket_types.event_id = events.id
          AND ticket_types.name = 'General admission'
        ORDER BY id
        LIMIT 1
      )
    SQL

    change_column_null :events, :price_cents, false
    add_check_constraint :events, "price_cents >= 0", name: "events_price_cents_non_negative"

    execute <<~SQL.squish
      DELETE FROM ticket_types
      WHERE name = 'General admission'
        AND description IS NULL
        AND sales_starts_at IS NULL
        AND sales_ends_at IS NULL
        AND NOT EXISTS (
          SELECT 1 FROM tickets WHERE tickets.ticket_type_id = ticket_types.id
        )
    SQL
  end
end
