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

ActiveRecord::Schema[8.1].define(version: 2025_10_10_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "dummy_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "updated_at", null: false
  end

  create_table "subs_engine_customers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "external_id", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "stripe_customer_id"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_subs_engine_customers_on_email"
    t.index ["external_id"], name: "index_subs_engine_customers_on_external_id", unique: true
    t.index ["stripe_customer_id"], name: "index_subs_engine_customers_on_stripe_customer_id", unique: true
  end

  create_table "subs_engine_plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "amount_cents", null: false
    t.datetime "created_at", null: false
    t.string "currency", limit: 3, null: false
    t.integer "interval", default: 0, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.string "stripe_price_id"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_subs_engine_plans_on_active"
    t.index ["slug"], name: "index_subs_engine_plans_on_slug", unique: true
    t.index ["stripe_price_id"], name: "index_subs_engine_plans_on_stripe_price_id", unique: true
  end

  create_table "subs_engine_subscription_transitions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}, null: false
    t.boolean "most_recent", default: false, null: false
    t.integer "sort_key", null: false
    t.uuid "subscription_id", null: false
    t.string "to_state", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_id", "most_recent"], name: "idx_subs_engine_sub_transitions_most_recent", unique: true, where: "most_recent"
    t.index ["subscription_id", "sort_key"], name: "idx_subs_engine_sub_transitions_sort_key", unique: true
    t.index ["subscription_id"], name: "index_subs_engine_subscription_transitions_on_subscription_id"
  end

  create_table "subs_engine_subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "canceled_at"
    t.datetime "created_at", null: false
    t.datetime "current_period_end"
    t.datetime "current_period_start"
    t.uuid "customer_id", null: false
    t.jsonb "metadata", default: {}, null: false
    t.uuid "plan_id", null: false
    t.string "stripe_subscription_id"
    t.datetime "trial_end"
    t.datetime "updated_at", null: false
    t.index ["customer_id", "plan_id"], name: "index_subs_engine_subscriptions_on_customer_id_and_plan_id"
    t.index ["customer_id"], name: "index_subs_engine_subscriptions_on_customer_id"
    t.index ["plan_id"], name: "index_subs_engine_subscriptions_on_plan_id"
    t.index ["stripe_subscription_id"], name: "index_subs_engine_subscriptions_on_stripe_subscription_id", unique: true
  end

  create_table "subs_engine_webhook_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "event_type", null: false
    t.jsonb "payload", default: {}, null: false
    t.integer "status", default: 0, null: false
    t.string "stripe_event_id", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_subs_engine_webhook_events_on_event_type"
    t.index ["status"], name: "index_subs_engine_webhook_events_on_status"
    t.index ["stripe_event_id"], name: "index_subs_engine_webhook_events_on_stripe_event_id", unique: true
  end

  add_foreign_key "subs_engine_subscription_transitions", "subs_engine_subscriptions", column: "subscription_id"
  add_foreign_key "subs_engine_subscriptions", "subs_engine_customers", column: "customer_id"
  add_foreign_key "subs_engine_subscriptions", "subs_engine_plans", column: "plan_id"
end
