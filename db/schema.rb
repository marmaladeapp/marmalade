# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160402233015) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abstracts", force: :cascade do |t|
    t.integer  "context_id"
    t.string   "context_type"
    t.integer  "item_id"
    t.string   "item_type"
    t.integer  "project_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "user_id"
    t.string   "action"
    t.decimal  "value"
    t.string   "currency"
    t.integer  "sub_item_id"
    t.string   "sub_item_type"
  end

  add_index "abstracts", ["context_type", "context_id"], name: "index_abstracts_on_context_type_and_context_id", using: :btree
  add_index "abstracts", ["item_type", "item_id"], name: "index_abstracts_on_item_type_and_item_id", using: :btree
  add_index "abstracts", ["project_id"], name: "index_abstracts_on_project_id", using: :btree
  add_index "abstracts", ["sub_item_type", "sub_item_id"], name: "index_abstracts_on_sub_item_type_and_sub_item_id", using: :btree
  add_index "abstracts", ["user_id"], name: "index_abstracts_on_user_id", using: :btree

  create_table "businesses", force: :cascade do |t|
    t.string   "name"
    t.string   "slug"
    t.text     "description"
    t.string   "business_type", default: "LimitedCompany", null: false
    t.string   "country",       default: "US",             null: false
    t.string   "time_zone",     default: "UTC",            null: false
    t.string   "currency",      default: "USD",            null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "user_id"
  end

  add_index "businesses", ["user_id"], name: "index_businesses_on_user_id", using: :btree

  create_table "calendar_calendars", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "slug"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "calendar_calendars", ["owner_type", "owner_id"], name: "index_calendar_calendars_on_owner_type_and_owner_id", using: :btree
  add_index "calendar_calendars", ["slug"], name: "index_calendar_calendars_on_slug", using: :btree
  add_index "calendar_calendars", ["user_id"], name: "index_calendar_calendars_on_user_id", using: :btree

  create_table "calendar_events", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "context_id"
    t.string   "context_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "starting_at"
    t.datetime "ending_at"
    t.integer  "project_id"
  end

  add_index "calendar_events", ["context_type", "context_id"], name: "index_calendar_events_on_context_type_and_context_id", using: :btree
  add_index "calendar_events", ["ending_at"], name: "index_calendar_events_on_ending_at", using: :btree
  add_index "calendar_events", ["project_id"], name: "index_calendar_events_on_project_id", using: :btree
  add_index "calendar_events", ["starting_at"], name: "index_calendar_events_on_starting_at", using: :btree

  create_table "categorizations", force: :cascade do |t|
    t.integer  "category_id"
    t.string   "category_type"
    t.integer  "item_id"
    t.string   "item_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "categorizations", ["category_type", "category_id"], name: "index_categorizations_on_category_type_and_category_id", using: :btree
  add_index "categorizations", ["item_type", "item_id"], name: "index_categorizations_on_item_type_and_item_id", using: :btree

  create_table "collaborators", force: :cascade do |t|
    t.integer  "collaborator_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "user_id"
  end

  add_index "collaborators", ["collaborator_id"], name: "index_collaborators_on_collaborator_id", using: :btree
  add_index "collaborators", ["user_id"], name: "index_collaborators_on_user_id", using: :btree

  create_table "contact_details_addresses", force: :cascade do |t|
    t.string   "line_1"
    t.string   "line_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "contact_details_addresses", ["owner_type", "owner_id"], name: "index_contact_details_addresses_on_owner_type_and_owner_id", using: :btree

  create_table "contact_details_emails", force: :cascade do |t|
    t.string   "address"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "contact_details_emails", ["address"], name: "index_contact_details_emails_on_address", using: :btree
  add_index "contact_details_emails", ["owner_type", "owner_id"], name: "index_contact_details_emails_on_owner_type_and_owner_id", using: :btree

  create_table "contact_details_telephones", force: :cascade do |t|
    t.string   "number"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "country_code"
  end

  add_index "contact_details_telephones", ["owner_type", "owner_id"], name: "index_contact_details_telephones_on_owner_type_and_owner_id", using: :btree

  create_table "contacts_address_books", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.text     "description"
    t.string   "slug"
  end

  add_index "contacts_address_books", ["owner_type", "owner_id"], name: "index_contacts_address_books_on_owner_type_and_owner_id", using: :btree
  add_index "contacts_address_books", ["slug"], name: "index_contacts_address_books_on_slug", using: :btree
  add_index "contacts_address_books", ["user_id"], name: "index_contacts_address_books_on_user_id", using: :btree

  create_table "contacts_contacts", force: :cascade do |t|
    t.string   "name"
    t.integer  "context_id"
    t.string   "context_type"
    t.integer  "item_id"
    t.string   "item_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "contacts_contacts", ["context_type", "context_id"], name: "index_contacts_contacts_on_context_type_and_context_id", using: :btree
  add_index "contacts_contacts", ["item_type", "item_id"], name: "index_contacts_contacts_on_item_type_and_item_id", using: :btree

  create_table "finances_balance_sheets", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.decimal  "net_worth"
    t.decimal  "total_assets"
    t.decimal  "current_assets"
    t.decimal  "fixed_assets"
    t.decimal  "total_liabilities"
    t.decimal  "current_liabilities"
    t.decimal  "long_term_liabilities"
    t.decimal  "cash"
    t.decimal  "total_ledgers_receivable"
    t.decimal  "total_ledgers_debt"
    t.decimal  "total_wallets"
    t.string   "currency"
    t.integer  "item_id"
    t.string   "item_type"
    t.string   "action"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.decimal  "capital_assets",           default: 0.0, null: false
    t.decimal  "inventory",                default: 0.0, null: false
  end

  add_index "finances_balance_sheets", ["item_type", "item_id"], name: "index_finances_balance_sheets_on_item_type_and_item_id", using: :btree
  add_index "finances_balance_sheets", ["owner_type", "owner_id"], name: "index_finances_balance_sheets_on_owner_type_and_owner_id", using: :btree

  create_table "finances_ledgers", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "value"
    t.decimal  "starting_value"
    t.string   "currency"
    t.datetime "due_in_full_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "context_id"
    t.string   "context_type"
    t.integer  "counterparty_id"
    t.string   "counterparty_type"
    t.integer  "counterledger_id"
    t.integer  "project_id"
    t.string   "fiscal_class"
  end

  add_index "finances_ledgers", ["context_type", "context_id"], name: "index_finances_ledgers_on_context_type_and_context_id", using: :btree
  add_index "finances_ledgers", ["counterledger_id"], name: "index_finances_ledgers_on_counterledger_id", using: :btree
  add_index "finances_ledgers", ["counterparty_type", "counterparty_id"], name: "index_finances_ledgers_on_counterparty_type_and_counterparty_id", using: :btree
  add_index "finances_ledgers", ["project_id"], name: "index_finances_ledgers_on_project_id", using: :btree

  create_table "finances_payments", force: :cascade do |t|
    t.text     "description"
    t.decimal  "value",                                    null: false
    t.string   "currency",                 default: "USD", null: false
    t.integer  "wallet_id"
    t.integer  "ledger_id"
    t.decimal  "wallet_balance"
    t.decimal  "ledger_balance"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "project_id"
    t.integer  "inventory_item_id"
    t.integer  "inventory_stock_sheet_id"
  end

  add_index "finances_payments", ["inventory_item_id"], name: "index_finances_payments_on_inventory_item_id", using: :btree
  add_index "finances_payments", ["inventory_stock_sheet_id"], name: "index_finances_payments_on_inventory_stock_sheet_id", using: :btree
  add_index "finances_payments", ["ledger_id"], name: "index_finances_payments_on_ledger_id", using: :btree
  add_index "finances_payments", ["project_id"], name: "index_finances_payments_on_project_id", using: :btree
  add_index "finances_payments", ["wallet_id"], name: "index_finances_payments_on_wallet_id", using: :btree

  create_table "finances_wallets", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "balance"
    t.decimal  "starting_balance"
    t.string   "currency"
    t.datetime "starting_date"
    t.integer  "user_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "context_id"
    t.string   "context_type"
  end

  add_index "finances_wallets", ["context_type", "context_id"], name: "index_finances_wallets_on_context_type_and_context_id", using: :btree
  add_index "finances_wallets", ["user_id"], name: "index_finances_wallets_on_user_id", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "country"
    t.string   "time_zone"
    t.string   "currency"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "households", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "country",     default: "US",  null: false
    t.string   "time_zone",   default: "UTC", null: false
    t.string   "currency",    default: "USD", null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "user_id"
  end

  add_index "households", ["user_id"], name: "index_households_on_user_id", using: :btree

  create_table "inventory_containers", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "slug"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "inventory_containers", ["owner_type", "owner_id"], name: "index_inventory_containers_on_owner_type_and_owner_id", using: :btree
  add_index "inventory_containers", ["user_id"], name: "index_inventory_containers_on_user_id", using: :btree

  create_table "inventory_items", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "context_id"
    t.string   "context_type"
    t.integer  "project_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.decimal  "starting_value",      default: 0.0
    t.decimal  "value",               default: 0.0
    t.decimal  "ending_value",        default: 0.0
    t.string   "currency"
    t.integer  "quantity",            default: 0
    t.boolean  "consumable"
    t.boolean  "saleable"
    t.decimal  "unit_starting_value", default: 0.0
    t.decimal  "unit_value",          default: 0.0
    t.decimal  "unit_ending_value",   default: 0.0
    t.integer  "total_quantity",      default: 0
    t.integer  "total_sold",          default: 0
  end

  add_index "inventory_items", ["context_type", "context_id"], name: "index_inventory_items_on_context_type_and_context_id", using: :btree
  add_index "inventory_items", ["project_id"], name: "index_inventory_items_on_project_id", using: :btree

  create_table "inventory_stock_sheets", force: :cascade do |t|
    t.integer  "inventory_item_id"
    t.integer  "quantity"
    t.integer  "quantity_difference"
    t.decimal  "unit_value"
    t.decimal  "unit_value_difference"
    t.decimal  "total_value"
    t.decimal  "total_value_difference"
    t.string   "currency"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "inventory_stock_sheets", ["inventory_item_id"], name: "index_inventory_stock_sheets_on_inventory_item_id", using: :btree

  create_table "item_wallets", force: :cascade do |t|
    t.integer  "item_id"
    t.string   "item_type"
    t.integer  "finances_wallet_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "item_wallets", ["finances_wallet_id"], name: "index_item_wallets_on_finances_wallet_id", using: :btree
  add_index "item_wallets", ["item_type", "item_id"], name: "index_item_wallets_on_item_type_and_item_id", using: :btree

  create_table "memberships", force: :cascade do |t|
    t.integer  "collective_id"
    t.string   "collective_type"
    t.integer  "member_id"
    t.string   "member_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "user_id"
  end

  add_index "memberships", ["collective_type", "collective_id"], name: "index_memberships_on_collective_type_and_collective_id", using: :btree
  add_index "memberships", ["member_type", "member_id"], name: "index_memberships_on_member_type_and_member_id", using: :btree
  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id", using: :btree

  create_table "messages_messages", force: :cascade do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "context_id"
    t.string   "context_type"
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "messages_messages", ["context_type", "context_id"], name: "index_messages_messages_on_context_type_and_context_id", using: :btree
  add_index "messages_messages", ["project_id"], name: "index_messages_messages_on_project_id", using: :btree
  add_index "messages_messages", ["user_id"], name: "index_messages_messages_on_user_id", using: :btree

  create_table "ownership_ancestries", force: :cascade do |t|
    t.integer  "ownership_id"
    t.string   "ancestry"
    t.integer  "ancestry_depth", default: 0
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "item_class"
  end

  add_index "ownership_ancestries", ["ancestry"], name: "index_ownership_ancestries_on_ancestry", using: :btree
  add_index "ownership_ancestries", ["item_class"], name: "index_ownership_ancestries_on_item_class", using: :btree
  add_index "ownership_ancestries", ["ownership_id"], name: "index_ownership_ancestries_on_ownership_id", using: :btree

  create_table "ownerships", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "item_id"
    t.string   "item_type"
    t.decimal  "equity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  add_index "ownerships", ["item_type", "item_id"], name: "index_ownerships_on_item_type_and_item_id", using: :btree
  add_index "ownerships", ["owner_type", "owner_id"], name: "index_ownerships_on_owner_type_and_owner_id", using: :btree
  add_index "ownerships", ["user_id"], name: "index_ownerships_on_user_id", using: :btree

  create_table "payment_methods", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "braintree_payment_method_token"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "payment_methods", ["user_id"], name: "index_payment_methods_on_user_id", using: :btree

  create_table "plans", force: :cascade do |t|
    t.string   "slug"
    t.string   "name"
    t.text     "description"
    t.decimal  "price"
    t.string   "currency"
    t.integer  "billing_frequency"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "collaborator_limit"
    t.integer  "wallet_limit"
    t.integer  "project_limit"
    t.integer  "business_limit",     default: 0
    t.integer  "household_limit",    default: 0
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "slug"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "projects", ["owner_type", "owner_id"], name: "index_projects_on_owner_type_and_owner_id", using: :btree
  add_index "projects", ["slug"], name: "index_projects_on_slug", using: :btree
  add_index "projects", ["user_id"], name: "index_projects_on_user_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "time_intervals", force: :cascade do |t|
    t.datetime "started_at"
    t.datetime "stopped_at"
    t.integer  "duration"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "time_timer_id"
    t.integer  "user_id"
    t.integer  "project_id"
  end

  add_index "time_intervals", ["project_id"], name: "index_time_intervals_on_project_id", using: :btree
  add_index "time_intervals", ["started_at"], name: "index_time_intervals_on_started_at", using: :btree
  add_index "time_intervals", ["stopped_at"], name: "index_time_intervals_on_stopped_at", using: :btree
  add_index "time_intervals", ["time_timer_id"], name: "index_time_intervals_on_time_timer_id", using: :btree
  add_index "time_intervals", ["user_id"], name: "index_time_intervals_on_user_id", using: :btree

  create_table "time_time_sheets", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "slug"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "time_time_sheets", ["owner_type", "owner_id"], name: "index_time_time_sheets_on_owner_type_and_owner_id", using: :btree
  add_index "time_time_sheets", ["slug"], name: "index_time_time_sheets_on_slug", using: :btree
  add_index "time_time_sheets", ["user_id"], name: "index_time_time_sheets_on_user_id", using: :btree

  create_table "time_timers", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "context_id"
    t.string   "context_type"
    t.integer  "estimated_time",  default: 0
    t.integer  "elapsed_time",    default: 0
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "intervals_count", default: 0
    t.integer  "project_id"
    t.string   "repeats"
    t.text     "occuring_on",                              array: true
    t.datetime "scheduled_at"
    t.integer  "frequency"
    t.datetime "last_active_at"
  end

  add_index "time_timers", ["context_type", "context_id"], name: "index_time_timers_on_context_type_and_context_id", using: :btree
  add_index "time_timers", ["frequency"], name: "index_time_timers_on_frequency", using: :btree
  add_index "time_timers", ["occuring_on"], name: "index_time_timers_on_occuring_on", using: :btree
  add_index "time_timers", ["project_id"], name: "index_time_timers_on_project_id", using: :btree
  add_index "time_timers", ["repeats"], name: "index_time_timers_on_repeats", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                     default: "",      null: false
    t.string   "encrypted_password",        default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",         default: 0
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "username"
    t.string   "first_name"
    t.string   "last_name"
    t.text     "bio"
    t.string   "currency",                  default: "USD",   null: false
    t.string   "time_zone",                 default: "UTC",   null: false
    t.string   "country",                   default: "US",    null: false
    t.string   "language",                  default: "en-US", null: false
    t.integer  "plan_id"
    t.string   "braintree_customer_id"
    t.string   "braintree_subscription_id"
    t.integer  "collaborators_count",       default: 0
    t.integer  "wallets_count",             default: 0
    t.integer  "projects_count",            default: 0
    t.integer  "households_count",          default: 0
    t.integer  "businesses_count",          default: 0
    t.integer  "groups_count",              default: 0
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["plan_id"], name: "index_users_on_plan_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "vanity_urls", force: :cascade do |t|
    t.string  "slug"
    t.string  "target"
    t.integer "owner_id"
    t.string  "owner_type"
  end

  add_index "vanity_urls", ["owner_type", "owner_id"], name: "index_vanity_urls_on_owner_type_and_owner_id", using: :btree
  add_index "vanity_urls", ["slug"], name: "index_vanity_urls_on_slug", unique: true, using: :btree

  add_foreign_key "abstracts", "projects"
  add_foreign_key "abstracts", "users"
  add_foreign_key "businesses", "users"
  add_foreign_key "calendar_calendars", "users"
  add_foreign_key "calendar_events", "projects"
  add_foreign_key "collaborators", "users"
  add_foreign_key "contacts_address_books", "users"
  add_foreign_key "finances_ledgers", "projects"
  add_foreign_key "finances_payments", "inventory_items"
  add_foreign_key "finances_payments", "inventory_stock_sheets"
  add_foreign_key "finances_payments", "projects"
  add_foreign_key "finances_wallets", "users"
  add_foreign_key "households", "users"
  add_foreign_key "inventory_containers", "users"
  add_foreign_key "inventory_items", "projects"
  add_foreign_key "inventory_stock_sheets", "inventory_items"
  add_foreign_key "item_wallets", "finances_wallets"
  add_foreign_key "memberships", "users"
  add_foreign_key "messages_messages", "projects"
  add_foreign_key "messages_messages", "users"
  add_foreign_key "ownership_ancestries", "ownerships"
  add_foreign_key "ownerships", "users"
  add_foreign_key "payment_methods", "users"
  add_foreign_key "projects", "users"
  add_foreign_key "time_intervals", "projects"
  add_foreign_key "time_intervals", "time_timers"
  add_foreign_key "time_intervals", "users"
  add_foreign_key "time_time_sheets", "users"
  add_foreign_key "time_timers", "projects"
  add_foreign_key "users", "plans"
end
