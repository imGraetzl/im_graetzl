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

ActiveRecord::Schema.define(version: 20150929221802) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body"
    t.string   "resource_id",   limit: 255, null: false
    t.string   "resource_type", limit: 255, null: false
    t.integer  "author_id"
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type", limit: 255
    t.integer  "owner_id"
    t.string   "owner_type",     limit: 255
    t.string   "key",            limit: 255
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.string   "street_name",      limit: 255
    t.string   "street_number",    limit: 255
    t.string   "zip",              limit: 255
    t.string   "city",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.geometry "coordinates",      limit: {:srid=>0, :type=>"point"}
    t.integer  "addressable_id"
    t.string   "addressable_type", limit: 255
    t.string   "description",      limit: 255
  end

  add_index "addresses", ["addressable_id", "addressable_type"], name: "index_addresses_on_addressable_id_and_addressable_type", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "context",                default: 0
  end

  create_table "categorizations", force: :cascade do |t|
    t.integer  "category_id"
    t.integer  "categorizable_id"
    t.string   "categorizable_type"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "categorizations", ["categorizable_type", "categorizable_id"], name: "idx_categorizations_on_categorizable", using: :btree
  add_index "categorizations", ["category_id"], name: "index_categorizations_on_category_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.string   "website"
    t.string   "email"
    t.string   "phone"
    t.integer  "location_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "contacts", ["location_id"], name: "index_contacts_on_location_id", using: :btree

  create_table "districts", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "zip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.geometry "area",       limit: {:srid=>0, :type=>"polygon"}
    t.string   "slug",       limit: 255
  end

  add_index "districts", ["slug"], name: "index_districts_on_slug", using: :btree

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",               null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope",          limit: 255
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "going_tos", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "meeting_id"
    t.integer  "role",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "going_tos", ["meeting_id"], name: "index_going_tos_on_meeting_id", using: :btree
  add_index "going_tos", ["user_id"], name: "index_going_tos_on_user_id", using: :btree

  create_table "graetzls", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.geometry "area",       limit: {:srid=>0, :type=>"polygon"}
    t.string   "slug",       limit: 255
    t.integer  "state",                                           default: 0
  end

  add_index "graetzls", ["slug"], name: "index_graetzls_on_slug", using: :btree

  create_table "images", force: :cascade do |t|
    t.string   "file_id"
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "file_content_type"
  end

  add_index "images", ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id", using: :btree

  create_table "location_ownerships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "location_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "state",       default: 0
  end

  add_index "location_ownerships", ["location_id"], name: "index_location_ownerships_on_location_id", using: :btree
  add_index "location_ownerships", ["user_id"], name: "index_location_ownerships_on_user_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "name"
    t.string   "slogan"
    t.text     "description"
    t.string   "avatar_id"
    t.string   "cover_photo_id"
    t.string   "slug"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "graetzl_id"
    t.string   "avatar_content_type"
    t.string   "cover_photo_content_type"
    t.integer  "state",                    default: 0
  end

  add_index "locations", ["graetzl_id"], name: "index_locations_on_graetzl_id", using: :btree
  add_index "locations", ["slug"], name: "index_locations_on_slug", using: :btree

  create_table "meetings", force: :cascade do |t|
    t.string   "name",                     limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",                     limit: 255
    t.date     "starts_at_date"
    t.date     "ends_at_date"
    t.time     "starts_at_time"
    t.time     "ends_at_time"
    t.integer  "graetzl_id"
    t.string   "cover_photo_id"
    t.string   "cover_photo_content_type"
    t.integer  "location_id"
    t.integer  "state",                                default: 0
  end

  add_index "meetings", ["graetzl_id"], name: "index_meetings_on_graetzl_id", using: :btree
  add_index "meetings", ["location_id"], name: "index_meetings_on_location_id", using: :btree
  add_index "meetings", ["slug"], name: "index_meetings_on_slug", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.integer  "bitmask",                            null: false
    t.boolean  "seen",               default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sent",               default: false
    t.boolean  "display_on_website", default: false
  end

  create_table "posts", force: :cascade do |t|
    t.text     "content"
    t.integer  "graetzl_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  add_index "posts", ["graetzl_id"], name: "index_posts_on_graetzl_id", using: :btree
  add_index "posts", ["slug"], name: "index_posts_on_slug", unique: true, using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                         limit: 255, default: "",    null: false
    t.string   "encrypted_password",            limit: 255, default: "",    null: false
    t.string   "reset_password_token",          limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                             default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",            limit: 255
    t.string   "last_sign_in_ip",               limit: 255
    t.string   "confirmation_token",            limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",                      limit: 255
    t.string   "first_name",                    limit: 255
    t.string   "last_name",                     limit: 255
    t.date     "birthday"
    t.integer  "gender"
    t.boolean  "newsletter",                                default: false, null: false
    t.integer  "graetzl_id"
    t.string   "avatar_id"
    t.integer  "enabled_website_notifications",             default: 2047
    t.integer  "role"
    t.string   "avatar_content_type"
    t.integer  "immediate_mail_notifications",              default: 2015
    t.integer  "daily_mail_notifications",                  default: 32
    t.integer  "weekly_mail_notifications",                 default: 0
    t.string   "slug"
    t.string   "cover_photo_id"
    t.string   "cover_photo_content_type"
    t.text     "bio"
    t.string   "website"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["graetzl_id"], name: "index_users_on_graetzl_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

end
