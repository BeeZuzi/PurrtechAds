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

ActiveRecord::Schema[8.1].define(version: 2026_07_18_182325) do
  create_table "contract_requests", force: :cascade do |t|
    t.string "contact_email", null: false
    t.string "country_code", null: false
    t.datetime "created_at", null: false
    t.string "entity_type", null: false
    t.string "legal_name", null: false
    t.text "message"
    t.string "payout_method", null: false
    t.string "phone"
    t.string "preferred_currency", default: "USD", null: false
    t.text "registered_address"
    t.integer "server_id", null: false
    t.string "status", default: "pending", null: false
    t.string "tax_id"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["server_id"], name: "index_contract_requests_on_server_id"
    t.index ["user_id"], name: "index_contract_requests_on_user_id"
  end

  create_table "servers", force: :cascade do |t|
    t.string "api_key", null: false
    t.string "api_secret", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["api_key"], name: "index_servers_on_api_key", unique: true
    t.index ["name"], name: "index_servers_on_name"
    t.index ["user_id"], name: "index_servers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "minecraft_nick", null: false
    t.string "password_digest", null: false
    t.string "role", default: "user", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["minecraft_nick"], name: "index_users_on_minecraft_nick", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "contract_requests", "servers"
  add_foreign_key "contract_requests", "users"
  add_foreign_key "servers", "users"
end
