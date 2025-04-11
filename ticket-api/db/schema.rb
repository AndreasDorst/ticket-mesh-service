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

ActiveRecord::Schema[7.1].define(version: 2025_04_11_113838) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blocked_tickets", force: :cascade do |t|
    t.bigint "ticket_id", null: false
    t.string "document_number", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticket_id"], name: "index_blocked_tickets_on_ticket_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "ticket_id", null: false
    t.datetime "expires_at", precision: nil
    t.string "user_document", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticket_id"], name: "index_bookings_on_ticket_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.bigint "ticket_id", null: false
    t.string "user_id"
    t.datetime "timestamp", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticket_id"], name: "index_purchases_on_ticket_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.string "category"
    t.integer "status"
    t.decimal "price"
    t.string "event"
    t.date "event_date"
    t.decimal "base_price"
    t.integer "sold_percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "blocked_tickets", "tickets"
  add_foreign_key "bookings", "tickets"
  add_foreign_key "purchases", "tickets"
end
