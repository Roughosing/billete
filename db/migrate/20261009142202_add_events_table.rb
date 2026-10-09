class AddEventsTable < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :location, null: false
      t.string :time_zone, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.integer :capacity, null: false
      t.integer :price_cents, null: false
      t.string :currency, null: false, default: "EUR"
      t.datetime :published_at
      t.timestamps
    end

    add_check_constraint :events, "ends_at > starts_at", name: "events_ends_after_start"
    add_check_constraint :events, "capacity > 0", name: "events_capacity_positive"
    add_check_constraint :events, "price_cents >= 0", name: "events_price_cents_non_negative"
    add_index :events, :starts_at
  end
end
