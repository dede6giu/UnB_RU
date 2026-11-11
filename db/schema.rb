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

ActiveRecord::Schema[8.1].define(version: 2026_11_04_021653) do
  create_table "accounts", primary_key: "user", id: :string, force: :cascade do |t|
    t.string "name"
    t.string "password_digest"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "restaurants", force: :cascade do |t|
    t.string "name"
    t.string "campus"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "campus"], name: "index_restaurants_on_name_and_campus", unique: true
  end

  create_table "students", primary_key: "user", id: :string, force: :cascade do |t|
    t.integer "balance_cents", default: 0, null: false
    t.datetime "blocked_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.string "student_id", null: false
    t.integer "access_id"
    t.string "kind", null: false
    t.string "payment_method"
    t.integer "amount_cents", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_id"], name: "index_transactions_on_access_id"
    t.index ["student_id"], name: "index_transactions_on_student_id"
  end

  create_table "turnstiles", force: :cascade do |t|
    t.string "name"
    t.string "operation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "restaurant_id", null: false
    t.integer "operator_id"
    t.index ["name", "restaurant_id"], name: "index_turnstiles_on_name_and_restaurant_id", unique: true
    t.index ["operator_id"], name: "index_turnstiles_on_operator_id"
    t.index ["restaurant_id"], name: "index_turnstiles_on_restaurant_id"
  end

  add_foreign_key "students", "accounts", column: "user", primary_key: "user"
  add_foreign_key "transactions", "students", primary_key: "user"
  add_foreign_key "turnstiles", "accounts", column: "operator_id"
  add_foreign_key "turnstiles", "restaurants"
end
