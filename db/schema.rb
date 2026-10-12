# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_12_095129) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "events", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "location", null: false
    t.string "time_zone", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "currency", default: "EUR", null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_events_on_organization_id"
    t.index ["starts_at"], name: "index_events_on_starts_at"
    t.check_constraint "ends_at > starts_at", name: "events_ends_after_start"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "organization_id", null: false
    t.string "role", default: "staff", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["user_id"], name: "index_memberships_on_user_id", unique: true
    t.check_constraint "role::text = ANY (ARRAY['staff'::character varying, 'admin'::character varying]::text[])", name: "memberships_role_check"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "ticket_types", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "quantity", null: false
    t.datetime "sales_starts_at"
    t.datetime "sales_ends_at"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_ticket_types_on_event_id"
    t.index ["id", "event_id"], name: "index_ticket_types_on_id_and_event_id", unique: true
    t.check_constraint "price >= 0::numeric", name: "ticket_types_price_non_negative"
    t.check_constraint "quantity > 0", name: "ticket_types_quantity_positive"
    t.check_constraint "sales_starts_at IS NULL OR sales_ends_at IS NULL OR sales_ends_at > sales_starts_at", name: "ticket_types_sales_end_after_start"
  end

  create_table "tickets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.bigint "ticket_type_id", null: false
    t.string "status", default: "confirmed", null: false
    t.string "code", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "currency", default: "EUR", null: false
    t.datetime "issued_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_tickets_on_code", unique: true
    t.index ["event_id"], name: "index_tickets_on_event_id"
    t.index ["ticket_type_id"], name: "index_tickets_on_ticket_type_id"
    t.index ["user_id", "event_id"], name: "index_tickets_on_user_id_and_event_id"
    t.index ["user_id"], name: "index_tickets_on_user_id"
    t.check_constraint "price >= 0::numeric", name: "tickets_price_non_negative"
    t.check_constraint "status::text = ANY (ARRAY['confirmed'::character varying, 'cancelled'::character varying]::text[])", name: "tickets_status_check"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "unconfirmed_email"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "events", "organizations"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "ticket_types", "events"
  add_foreign_key "tickets", "events"
  add_foreign_key "tickets", "ticket_types", column: ["ticket_type_id", "event_id"], primary_key: ["id", "event_id"]
  add_foreign_key "tickets", "users"
end
