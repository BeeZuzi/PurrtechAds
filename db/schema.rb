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

ActiveRecord::Schema[8.1].define(version: 2026_10_28_120000) do
  create_table "claims", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "external_id"
    t.datetime "failed_at"
    t.string "ip_address"
    t.integer "payout_id"
    t.datetime "redeemed_at"
    t.integer "revenue_cents"
    t.integer "reward_cents"
    t.integer "server_id", null: false
    t.string "source", default: "simulated", null: false
    t.string "status", default: "pending", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.datetime "watched_at", null: false
    t.index ["external_id"], name: "index_claims_on_external_id", unique: true
    t.index ["ip_address"], name: "index_claims_on_ip_address"
    t.index ["payout_id"], name: "index_claims_on_payout_id"
    t.index ["server_id"], name: "index_claims_on_server_id"
    t.index ["status"], name: "index_claims_on_status"
    t.index ["token"], name: "index_claims_on_token", unique: true
    t.index ["user_id"], name: "index_claims_on_user_id"
  end

  create_table "contract_requests", force: :cascade do |t|
    t.string "contact_email", null: false
    t.string "country_code", null: false
    t.datetime "created_at", null: false
    t.string "entity_type", null: false
    t.string "legal_name", null: false
    t.text "message"
    t.string "payout_method", null: false
    t.string "phone"
    t.string "preferred_currency", default: "EUR", null: false
    t.text "registered_address"
    t.integer "server_id", null: false
    t.string "status", default: "pending", null: false
    t.string "tax_id"
    t.datetime "terms_accepted_at"
    t.string "terms_accepted_ip"
    t.string "terms_version"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["server_id"], name: "index_contract_requests_on_server_id"
    t.index ["user_id"], name: "index_contract_requests_on_user_id"
  end

  create_table "fraud_flags", force: :cascade do |t|
    t.integer "claim_id"
    t.datetime "created_at", null: false
    t.text "details"
    t.string "reason", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["claim_id"], name: "index_fraud_flags_on_claim_id"
    t.index ["status"], name: "index_fraud_flags_on_status"
    t.index ["user_id"], name: "index_fraud_flags_on_user_id"
  end

  create_table "payouts", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.integer "contract_request_id"
    t.datetime "created_at", null: false
    t.string "currency", default: "EUR", null: false
    t.text "notes"
    t.datetime "paid_at"
    t.text "recipient_snapshot"
    t.integer "requested_by_id"
    t.integer "server_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["contract_request_id"], name: "index_payouts_on_contract_request_id"
    t.index ["requested_by_id"], name: "index_payouts_on_requested_by_id"
    t.index ["server_id"], name: "index_payouts_on_server_id"
    t.index ["status"], name: "index_payouts_on_status"
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
    t.datetime "banned_at"
    t.datetime "banned_until"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "minecraft_nick", null: false
    t.string "minecraft_uuid"
    t.string "password_digest", null: false
    t.string "role", default: "user", null: false
    t.datetime "updated_at", null: false
    t.index ["banned_at"], name: "index_users_on_banned_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["minecraft_nick"], name: "index_users_on_minecraft_nick", unique: true
    t.index ["minecraft_uuid"], name: "index_users_on_minecraft_uuid", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "claims", "payouts"
  add_foreign_key "claims", "servers"
  add_foreign_key "claims", "users"
  add_foreign_key "contract_requests", "servers"
  add_foreign_key "contract_requests", "users"
  add_foreign_key "fraud_flags", "claims"
  add_foreign_key "fraud_flags", "users"
  add_foreign_key "payouts", "contract_requests"
  add_foreign_key "payouts", "servers"
  add_foreign_key "payouts", "users", column: "requested_by_id"
  add_foreign_key "servers", "users"
end
