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

ActiveRecord::Schema.define(version: 20150416150741) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "addresses", force: true do |t|
    t.integer  "user_id"
    t.string   "street_name"
    t.string   "street_number"
    t.string   "zip"
    t.string   "city"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "coordinates",   limit: {:srid=>0, :type=>"point"}
  end

  add_index "addresses", ["user_id"], :name => "index_addresses_on_user_id"

  create_table "graetzls", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.spatial  "area",       limit: {:srid=>0, :type=>"polygon"}
  end

  create_table "graetzls_meetings", id: false, force: true do |t|
    t.integer "graetzl_id"
    t.integer "meeting_id"
  end

  add_index "graetzls_meetings", ["graetzl_id"], :name => "index_graetzls_meetings_on_graetzl_id"
  add_index "graetzls_meetings", ["meeting_id"], :name => "index_graetzls_meetings_on_meeting_id"

  create_table "meetings", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "start"
    t.datetime "end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["graetzl_id"], :name => "index_users_on_graetzl_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
