class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true, index: false
      t.references :ticket_type, null: false, index: false
      t.string :status, null: false, default: "confirmed"
      t.string :code, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :currency, null: false, default: "EUR"
      t.datetime :issued_at, null: false

      t.timestamps
    end

    add_index :tickets, :code, unique: true
    add_index :tickets, :event_id
    add_index :tickets, :ticket_type_id
    add_index :tickets, [ :user_id, :event_id ]
    add_foreign_key :tickets, :ticket_types, column: [ :ticket_type_id, :event_id ], primary_key: [ :id, :event_id ]
    add_check_constraint :tickets, "status IN ('confirmed', 'cancelled')", name: "tickets_status_check"
    add_check_constraint :tickets, "price >= 0", name: "tickets_price_non_negative"
  end
end
