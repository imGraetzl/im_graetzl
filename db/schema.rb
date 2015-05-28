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

ActiveRecord::Schema.define(version: 20150528134228) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "activities", force: true do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], :name => "index_activities_on_owner_id_and_owner_type"
  add_index "activities", ["recipient_id", "recipient_type"], :name => "index_activities_on_recipient_id_and_recipient_type"
  add_index "activities", ["trackable_id", "trackable_type"], :name => "index_activities_on_trackable_id_and_trackable_type"

  create_table "addresses", force: true do |t|
    t.string   "street_name"
    t.string   "street_number"
    t.string   "zip"
    t.string   "city"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "coordinates",      limit: {:srid=>0, :type=>"point"}
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.string   "description"
  end

  add_index "addresses", ["addressable_id", "addressable_type"], :name => "index_addresses_on_addressable_id_and_addressable_type"

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories_meetings", id: false, force: true do |t|
    t.integer "category_id"
    t.integer "meeting_id"
  end

  add_index "categories_meetings", ["category_id"], :name => "index_categories_meetings_on_category_id"
  add_index "categories_meetings", ["meeting_id"], :name => "index_categories_meetings_on_meeting_id"

  create_table "districts", force: true do |t|
    t.string   "name"
    t.string   "zip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "area",       limit: {:srid=>0, :type=>"polygon"}
    t.string   "slug"
  end

  add_index "districts", ["slug"], :name => "index_districts_on_slug"

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", :unique => true
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type"
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "going_tos", force: true do |t|
    t.integer  "user_id"
    t.integer  "meeting_id"
    t.integer  "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "going_tos", ["meeting_id"], :name => "index_going_tos_on_meeting_id"
  add_index "going_tos", ["user_id"], :name => "index_going_tos_on_user_id"

  create_table "graetzls", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "area",       limit: {:srid=>0, :type=>"polygon"}
    t.string   "slug"
  end

  add_index "graetzls", ["slug"], :name => "index_graetzls_on_slug"

  create_table "meetings", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cover_photo"
    t.string   "slug"
    t.date     "starts_at_date"
    t.date     "ends_at_date"
    t.time     "starts_at_time"
    t.time     "ends_at_time"
    t.integer  "graetzl_id"
  end

  add_index "meetings", ["graetzl_id"], :name => "index_meetings_on_graetzl_id"
  add_index "meetings", ["slug"], :name => "index_meetings_on_slug"

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "first_name"
    t.string   "last_name"
    t.date     "birthday"
    t.integer  "gender"
    t.boolean  "newsletter",             default: false, null: false
    t.integer  "graetzl_id"
    t.string   "avatar"
    t.boolean  "admin"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["graetzl_id"], :name => "index_users_on_graetzl_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
