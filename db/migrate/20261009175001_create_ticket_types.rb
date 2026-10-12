class CreateTicketTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :ticket_types do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :quantity, null: false
      t.datetime :sales_starts_at
      t.datetime :sales_ends_at
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :ticket_types, [ :id, :event_id ], unique: true
    add_check_constraint :ticket_types, "price >= 0", name: "ticket_types_price_non_negative"
    add_check_constraint :ticket_types, "quantity > 0", name: "ticket_types_quantity_positive"
    add_check_constraint :ticket_types,
      "sales_starts_at IS NULL OR sales_ends_at IS NULL OR sales_ends_at > sales_starts_at",
      name: "ticket_types_sales_end_after_start"
  end
end
