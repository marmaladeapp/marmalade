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

ActiveRecord::Schema.define(version: 20160217184009) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  end

  add_index "contacts_address_books", ["owner_type", "owner_id"], name: "index_contacts_address_books_on_owner_type_and_owner_id", using: :btree
  add_index "contacts_address_books", ["user_id"], name: "index_contacts_address_books_on_user_id", using: :btree

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

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

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

  add_foreign_key "businesses", "users"
  add_foreign_key "collaborators", "users"
  add_foreign_key "contacts_address_books", "users"
  add_foreign_key "households", "users"
  add_foreign_key "memberships", "users"
  add_foreign_key "ownership_ancestries", "ownerships"
  add_foreign_key "ownerships", "users"
  add_foreign_key "payment_methods", "users"
  add_foreign_key "users", "plans"
end
