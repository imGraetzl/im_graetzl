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

ActiveRecord::Schema.define(version: 2022_05_03_120350) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "active_admin_comments", id: :serial, force: :cascade do |t|
    t.string "namespace", limit: 255
    t.text "body"
    t.string "resource_id", limit: 255, null: false
    t.string "resource_type", limit: 255, null: false
    t.integer "author_id"
    t.string "author_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "activities", id: :serial, force: :cascade do |t|
    t.integer "subject_id"
    t.string "subject_type", limit: 255
    t.integer "child_id"
    t.string "child_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "entire_region", default: false
    t.bigint "group_id"
    t.string "region_id"
    t.index ["child_id", "child_type"], name: "index_activities_on_child_id_and_child_type"
    t.index ["group_id"], name: "index_activities_on_group_id"
    t.index ["region_id"], name: "index_activities_on_region_id"
    t.index ["subject_id", "subject_type"], name: "index_activities_on_subject_id_and_subject_type"
  end

  create_table "activity_graetzls", force: :cascade do |t|
    t.bigint "activity_id"
    t.bigint "graetzl_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["activity_id"], name: "index_activity_graetzls_on_activity_id"
    t.index ["graetzl_id"], name: "index_activity_graetzls_on_graetzl_id"
  end

  create_table "api_accounts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "api_key"
    t.boolean "enabled", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "region_id"
    t.index ["region_id"], name: "index_api_accounts_on_region_id"
  end

  create_table "billing_addresses", id: :serial, force: :cascade do |t|
    t.integer "location_id"
    t.string "first_name"
    t.string "last_name"
    t.string "company"
    t.string "street"
    t.string "zip"
    t.string "city"
    t.string "country", default: "Austria"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "vat_id"
    t.index ["location_id"], name: "index_billing_addresses_on_location_id"
    t.index ["user_id"], name: "index_billing_addresses_on_user_id"
  end

  create_table "business_interests", id: :serial, force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "mailchimp_id"
  end

  create_table "business_interests_users", id: false, force: :cascade do |t|
    t.integer "business_interest_id"
    t.integer "user_id"
    t.index ["business_interest_id"], name: "index_business_interests_users_on_business_interest_id"
    t.index ["user_id"], name: "index_business_interests_users_on_user_id"
  end

  create_table "campaign_users", force: :cascade do |t|
    t.string "campaign_title"
    t.string "first_name"
    t.string "last_name"
    t.string "email", default: "", null: false
    t.string "website"
    t.string "zip"
    t.string "city"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories_meetings", id: false, force: :cascade do |t|
    t.integer "category_id"
    t.integer "meeting_id"
    t.index ["category_id"], name: "index_categories_meetings_on_category_id"
    t.index ["meeting_id"], name: "index_categories_meetings_on_meeting_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "user_id"
    t.integer "commentable_id"
    t.string "commentable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "contacts", id: :serial, force: :cascade do |t|
    t.string "website"
    t.string "email"
    t.string "phone"
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "hours"
    t.string "online_shop"
    t.index ["location_id"], name: "index_contacts_on_location_id"
  end

  create_table "coop_demand_categories", force: :cascade do |t|
    t.string "name"
    t.string "icon"
    t.integer "position", default: 0
    t.jsonb "main_photo_data"
    t.string "slug"
    t.index ["slug"], name: "index_coop_demand_categories_on_slug", unique: true
  end

  create_table "coop_demand_graetzls", force: :cascade do |t|
    t.bigint "coop_demand_id"
    t.bigint "graetzl_id"
    t.index ["coop_demand_id"], name: "index_coop_demand_graetzls_on_coop_demand_id"
    t.index ["graetzl_id"], name: "index_coop_demand_graetzls_on_graetzl_id"
  end

  create_table "coop_demands", force: :cascade do |t|
    t.string "slogan"
    t.text "demand_description"
    t.text "personal_description"
    t.string "slug"
    t.string "first_name"
    t.string "last_name"
    t.string "website"
    t.string "email"
    t.string "phone"
    t.integer "status", default: 0
    t.jsonb "avatar_data"
    t.string "region_id"
    t.date "last_activated_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.bigint "location_id"
    t.bigint "coop_demand_category_id"
    t.integer "coop_type", default: 0
    t.index ["coop_demand_category_id"], name: "index_coop_demands_on_coop_demand_category_id"
    t.index ["location_id"], name: "index_coop_demands_on_location_id"
    t.index ["region_id"], name: "index_coop_demands_on_region_id"
    t.index ["slug"], name: "index_coop_demands_on_slug"
    t.index ["user_id"], name: "index_coop_demands_on_user_id"
  end

  create_table "coop_suggested_tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "coop_demand_category_id"
    t.index ["coop_demand_category_id"], name: "index_coop_suggested_tags_on_coop_demand_category_id"
  end

  create_table "crowd_campaign_posts", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "region_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "crowd_campaign_id"
    t.bigint "graetzl_id"
    t.index ["crowd_campaign_id"], name: "index_crowd_campaign_posts_on_crowd_campaign_id"
    t.index ["graetzl_id"], name: "index_crowd_campaign_posts_on_graetzl_id"
    t.index ["region_id"], name: "index_crowd_campaign_posts_on_region_id"
  end

  create_table "crowd_campaigns", force: :cascade do |t|
    t.integer "status", default: 0
    t.string "slug"
    t.string "title"
    t.string "slogan"
    t.string "address_street"
    t.string "address_zip"
    t.string "address_city"
    t.string "address_description"
    t.geometry "address_coordinates", limit: {:srid=>0, :type=>"geometry"}
    t.text "description"
    t.text "support_description"
    t.text "about_description"
    t.text "benefit_description"
    t.decimal "funding_1_amount", precision: 10, scale: 2
    t.decimal "funding_2_amount", precision: 10, scale: 2
    t.text "funding_1_description"
    t.text "funding_2_description"
    t.date "startdate"
    t.date "enddate"
    t.boolean "benefit"
    t.integer "billable"
    t.string "video"
    t.string "cover_photo_id"
    t.string "cover_photo_content_type"
    t.jsonb "cover_photo_data"
    t.string "contact_company"
    t.string "contact_name"
    t.string "contact_address"
    t.string "contact_zip"
    t.string "contact_city"
    t.string "contact_website"
    t.string "contact_email"
    t.string "contact_phone"
    t.string "region_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.bigint "graetzl_id"
    t.bigint "location_id"
    t.bigint "room_offer_id"
    t.integer "funding_status", default: 0
    t.jsonb "avatar_data"
    t.index ["graetzl_id"], name: "index_crowd_campaigns_on_graetzl_id"
    t.index ["location_id"], name: "index_crowd_campaigns_on_location_id"
    t.index ["region_id"], name: "index_crowd_campaigns_on_region_id"
    t.index ["room_offer_id"], name: "index_crowd_campaigns_on_room_offer_id"
    t.index ["slug"], name: "index_crowd_campaigns_on_slug"
    t.index ["user_id"], name: "index_crowd_campaigns_on_user_id"
  end

  create_table "crowd_campaigns_categories", id: false, force: :cascade do |t|
    t.bigint "crowd_category_id", null: false
    t.bigint "crowd_campaign_id", null: false
    t.index ["crowd_campaign_id"], name: "index_crowd_campaigns_categories_on_crowd_campaign_id"
    t.index ["crowd_category_id"], name: "index_crowd_campaigns_categories_on_crowd_category_id"
  end

  create_table "crowd_categories", force: :cascade do |t|
    t.string "title"
    t.string "css_ico_class"
    t.string "main_photo_id"
    t.string "main_photo_content_type"
    t.jsonb "main_photo_data"
    t.string "slug"
    t.integer "position", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_crowd_categories_on_slug"
  end

  create_table "crowd_donation_pledges", force: :cascade do |t|
    t.integer "status", default: 0
    t.string "contact_name"
    t.string "region_id"
    t.text "answer"
    t.bigint "crowd_campaign_id"
    t.bigint "crowd_donation_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email"
    t.integer "donation_type"
    t.index ["crowd_campaign_id"], name: "index_crowd_donation_pledges_on_crowd_campaign_id"
    t.index ["crowd_donation_id"], name: "index_crowd_donation_pledges_on_crowd_donation_id"
    t.index ["region_id"], name: "index_crowd_donation_pledges_on_region_id"
    t.index ["user_id"], name: "index_crowd_donation_pledges_on_user_id"
  end

  create_table "crowd_donations", force: :cascade do |t|
    t.integer "donation_type", default: 0
    t.string "title"
    t.text "description"
    t.date "startdate"
    t.date "enddate"
    t.string "question"
    t.bigint "crowd_campaign_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "claimed", default: 0
    t.index ["crowd_campaign_id"], name: "index_crowd_donations_on_crowd_campaign_id"
  end

  create_table "crowd_pledges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "status", default: 0
    t.decimal "donation_amount", precision: 10, scale: 2
    t.string "contact_name"
    t.string "address_street"
    t.string "address_zip"
    t.string "address_city"
    t.string "region_id"
    t.text "answer"
    t.bigint "crowd_campaign_id"
    t.bigint "crowd_reward_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email"
    t.boolean "anonym", default: false
    t.decimal "total_price", precision: 10, scale: 2
    t.string "stripe_customer_id"
    t.string "stripe_payment_method_id"
    t.string "stripe_payment_intent_id"
    t.string "payment_method"
    t.string "payment_card_last4"
    t.boolean "terms", default: false
    t.index ["crowd_campaign_id"], name: "index_crowd_pledges_on_crowd_campaign_id"
    t.index ["crowd_reward_id"], name: "index_crowd_pledges_on_crowd_reward_id"
    t.index ["region_id"], name: "index_crowd_pledges_on_region_id"
    t.index ["user_id"], name: "index_crowd_pledges_on_user_id"
  end

  create_table "crowd_rewards", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.integer "limit"
    t.string "title"
    t.text "description"
    t.integer "delivery_weeks"
    t.boolean "delivery_address_required"
    t.string "question"
    t.jsonb "avatar_data"
    t.bigint "crowd_campaign_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "claimed", default: 0
    t.index ["crowd_campaign_id"], name: "index_crowd_rewards_on_crowd_campaign_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "discussion_categories", id: :serial, force: :cascade do |t|
    t.string "title"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_discussion_categories_on_group_id"
    t.index ["title"], name: "index_discussion_categories_on_title"
  end

  create_table "discussion_default_categories", id: :serial, force: :cascade do |t|
    t.string "title"
  end

  create_table "discussion_followings", id: :serial, force: :cascade do |t|
    t.integer "discussion_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discussion_id"], name: "index_discussion_followings_on_discussion_id"
    t.index ["user_id"], name: "index_discussion_followings_on_user_id"
  end

  create_table "discussion_posts", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "discussion_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "initial_post", default: false
    t.index ["discussion_id"], name: "index_discussion_posts_on_discussion_id"
    t.index ["user_id"], name: "index_discussion_posts_on_user_id"
  end

  create_table "discussions", id: :serial, force: :cascade do |t|
    t.string "title"
    t.boolean "closed", default: false
    t.boolean "sticky", default: false
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.datetime "last_post_at"
    t.integer "discussion_category_id"
    t.index ["discussion_category_id"], name: "index_discussions_on_discussion_category_id"
    t.index ["group_id", "sticky", "last_post_at"], name: "index_discussions_on_group_id_and_sticky_and_last_post_at"
    t.index ["group_id"], name: "index_discussions_on_group_id"
    t.index ["user_id"], name: "index_discussions_on_user_id"
  end

  create_table "district_graetzls", id: :serial, force: :cascade do |t|
    t.integer "district_id"
    t.integer "graetzl_id"
    t.index ["district_id"], name: "index_district_graetzls_on_district_id"
    t.index ["graetzl_id"], name: "index_district_graetzls_on_graetzl_id"
  end

  create_table "districts", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "zip", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.geometry "area", limit: {:srid=>0, :type=>"st_polygon"}
    t.string "slug", limit: 255
    t.string "region_id"
    t.index ["region_id"], name: "index_districts_on_region_id"
    t.index ["slug"], name: "index_districts_on_slug"
  end

  create_table "event_categories", force: :cascade do |t|
    t.string "title"
    t.string "css_ico_class"
    t.string "main_photo_id"
    t.string "main_photo_content_type"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "main_photo_data"
    t.string "slug"
    t.boolean "hidden", default: false
    t.index ["slug"], name: "index_event_categories_on_slug", unique: true
  end

  create_table "event_categories_meetings", id: false, force: :cascade do |t|
    t.bigint "event_category_id", null: false
    t.bigint "meeting_id", null: false
    t.index ["event_category_id"], name: "index_event_categories_meetings_on_event_category_id"
    t.index ["meeting_id"], name: "index_event_categories_meetings_on_meeting_id"
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", limit: 255, null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope", limit: 255
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "going_tos", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "meeting_id"
    t.integer "role", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "meeting_additional_date_id"
    t.decimal "amount", precision: 10, scale: 2
    t.integer "payment_status"
    t.string "payment_method"
    t.string "stripe_payment_intent_id"
    t.string "invoice_number"
    t.string "stripe_source_id"
    t.string "stripe_charge_id"
    t.date "going_to_date"
    t.time "going_to_time"
    t.index ["meeting_additional_date_id"], name: "index_going_tos_on_meeting_additional_date_id"
    t.index ["meeting_id"], name: "index_going_tos_on_meeting_id"
    t.index ["stripe_payment_intent_id"], name: "index_going_tos_on_stripe_payment_intent_id"
    t.index ["user_id"], name: "index_going_tos_on_user_id"
  end

  create_table "graetzls", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.geometry "area", limit: {:srid=>0, :type=>"st_polygon"}
    t.string "slug", limit: 255
    t.integer "users_count", default: 0
    t.string "region_id"
    t.string "zip"
    t.index ["region_id"], name: "index_graetzls_on_region_id"
    t.index ["slug"], name: "index_graetzls_on_slug"
  end

  create_table "group_categories", id: :serial, force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "group_categories_groups", id: false, force: :cascade do |t|
    t.integer "group_category_id", null: false
    t.integer "group_id", null: false
    t.index ["group_category_id"], name: "index_group_categories_groups_on_group_category_id"
    t.index ["group_id"], name: "index_group_categories_groups_on_group_id"
  end

  create_table "group_graetzls", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.integer "graetzl_id"
    t.index ["graetzl_id"], name: "index_group_graetzls_on_graetzl_id"
    t.index ["group_id"], name: "index_group_graetzls_on_group_id"
  end

  create_table "group_join_questions", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.text "question"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_join_questions_on_group_id"
  end

  create_table "group_join_requests", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "request_message"
    t.text "response_message"
    t.text "join_answers", default: [], array: true
    t.integer "status", default: 0
    t.index ["group_id"], name: "index_group_join_requests_on_group_id"
    t.index ["user_id"], name: "index_group_join_requests_on_user_id"
  end

  create_table "group_users", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.datetime "last_activity_at"
    t.index ["group_id"], name: "index_group_users_on_group_id"
    t.index ["user_id"], name: "index_group_users_on_user_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "room_offer_id"
    t.boolean "private", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "room_call_id"
    t.integer "room_demand_id"
    t.integer "location_id"
    t.string "cover_photo_id"
    t.string "cover_photo_content_type"
    t.boolean "featured", default: false
    t.boolean "hidden", default: false
    t.text "welcome_message"
    t.boolean "default_joined", default: false
    t.integer "group_users_count"
    t.jsonb "cover_photo_data"
    t.string "region_id"
    t.index ["location_id"], name: "index_groups_on_location_id"
    t.index ["region_id"], name: "index_groups_on_region_id"
    t.index ["room_call_id"], name: "index_groups_on_room_call_id"
    t.index ["room_demand_id"], name: "index_groups_on_room_demand_id"
    t.index ["room_offer_id"], name: "index_groups_on_room_offer_id"
  end

  create_table "images", id: :serial, force: :cascade do |t|
    t.string "file_id"
    t.integer "imageable_id"
    t.string "imageable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_content_type"
    t.jsonb "file_data"
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id"
  end

  create_table "location_categories", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "icon"
    t.string "main_photo_id"
    t.string "main_photo_content_type"
    t.integer "position", default: 0
    t.jsonb "main_photo_data"
    t.string "slug"
    t.index ["slug"], name: "index_location_categories_on_slug", unique: true
  end

  create_table "location_menus", force: :cascade do |t|
    t.date "menu_from"
    t.date "menu_to"
    t.string "title"
    t.text "description"
    t.text "day_0_description"
    t.text "day_1_description"
    t.text "day_2_description"
    t.text "day_3_description"
    t.text "day_4_description"
    t.text "day_5_description"
    t.text "day_6_description"
    t.string "region_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "location_id"
    t.bigint "graetzl_id"
    t.index ["graetzl_id"], name: "index_location_menus_on_graetzl_id"
    t.index ["location_id"], name: "index_location_menus_on_location_id"
    t.index ["region_id"], name: "index_location_menus_on_region_id"
  end

  create_table "location_ownerships", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "state", default: 0
    t.index ["location_id"], name: "index_location_ownerships_on_location_id"
    t.index ["user_id"], name: "index_location_ownerships_on_user_id"
  end

  create_table "location_posts", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "graetzl_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug"
    t.string "title"
    t.integer "location_id"
    t.string "author_type"
    t.index ["author_type", "location_id"], name: "index_location_posts_on_author_type_and_location_id"
    t.index ["created_at"], name: "index_location_posts_on_created_at"
    t.index ["graetzl_id"], name: "index_location_posts_on_graetzl_id"
    t.index ["slug"], name: "index_location_posts_on_slug", unique: true
  end

  create_table "locations", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "slogan"
    t.text "description"
    t.string "avatar_id"
    t.string "cover_photo_id"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "graetzl_id"
    t.string "avatar_content_type"
    t.string "cover_photo_content_type"
    t.integer "state", default: 0
    t.integer "location_category_id"
    t.datetime "last_activity_at"
    t.integer "user_id"
    t.integer "address_id"
    t.jsonb "avatar_data"
    t.jsonb "cover_photo_data"
    t.string "region_id"
    t.string "address_street"
    t.string "address_zip"
    t.string "address_city"
    t.geometry "address_coordinates", limit: {:srid=>0, :type=>"geometry"}
    t.string "address_description"
    t.string "website_url"
    t.string "online_shop_url"
    t.string "email"
    t.string "phone"
    t.string "open_hours"
    t.string "goodie"
    t.text "description_background"
    t.text "description_favorite_place"
    t.index ["address_id"], name: "index_locations_on_address_id"
    t.index ["created_at"], name: "index_locations_on_created_at"
    t.index ["graetzl_id"], name: "index_locations_on_graetzl_id"
    t.index ["last_activity_at"], name: "index_locations_on_last_activity_at"
    t.index ["region_id"], name: "index_locations_on_region_id"
    t.index ["slug"], name: "index_locations_on_slug"
    t.index ["user_id"], name: "index_locations_on_user_id"
  end

  create_table "meeting_additional_dates", force: :cascade do |t|
    t.bigint "meeting_id"
    t.date "starts_at_date"
    t.time "starts_at_time"
    t.time "ends_at_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meeting_id"], name: "index_meeting_additional_dates_on_meeting_id"
  end

  create_table "meetings", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "slug", limit: 255
    t.date "starts_at_date"
    t.date "ends_at_date"
    t.time "starts_at_time"
    t.time "ends_at_time"
    t.integer "graetzl_id"
    t.string "cover_photo_id"
    t.string "cover_photo_content_type"
    t.integer "location_id"
    t.integer "state", default: 0
    t.boolean "approved_for_api", default: false
    t.integer "group_id"
    t.boolean "private", default: false
    t.integer "user_id"
    t.boolean "online_meeting", default: false
    t.integer "address_id"
    t.text "online_description"
    t.jsonb "cover_photo_data"
    t.string "online_url"
    t.string "region_id"
    t.string "address_street"
    t.string "address_zip"
    t.string "address_city"
    t.geometry "address_coordinates", limit: {:srid=>0, :type=>"geometry"}
    t.string "address_description"
    t.index ["address_id"], name: "index_meetings_on_address_id"
    t.index ["created_at"], name: "index_meetings_on_created_at"
    t.index ["graetzl_id"], name: "index_meetings_on_graetzl_id"
    t.index ["group_id"], name: "index_meetings_on_group_id"
    t.index ["location_id"], name: "index_meetings_on_location_id"
    t.index ["region_id"], name: "index_meetings_on_region_id"
    t.index ["slug"], name: "index_meetings_on_slug"
    t.index ["user_id"], name: "index_meetings_on_user_id"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "bitmask", null: false
    t.boolean "seen", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "sent", default: false
    t.boolean "display_on_website", default: false
    t.string "type"
    t.date "notify_at"
    t.date "notify_before"
    t.string "subject_type"
    t.integer "subject_id"
    t.string "child_type"
    t.integer "child_id"
    t.string "region_id"
    t.index ["child_type", "child_id"], name: "index_notifications_on_child_type_and_child_id"
    t.index ["region_id"], name: "index_notifications_on_region_id"
    t.index ["subject_type", "subject_id"], name: "index_notifications_on_subject_type_and_subject_id"
    t.index ["user_id", "notify_at"], name: "index_notifications_on_user_id_and_notify_at"
  end

  create_table "region_calls", force: :cascade do |t|
    t.integer "region_type", default: 0
    t.string "region_id"
    t.string "gemeinden"
    t.string "name"
    t.string "personal_position"
    t.string "email", default: "", null: false
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "message"
  end

  create_table "room_call_fields", id: :serial, force: :cascade do |t|
    t.integer "room_call_id"
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_call_id"], name: "index_room_call_fields_on_room_call_id"
  end

  create_table "room_call_modules", id: :serial, force: :cascade do |t|
    t.integer "room_call_id"
    t.integer "room_module_id"
    t.integer "quantity", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["room_call_id"], name: "index_room_call_modules_on_room_call_id"
    t.index ["room_module_id"], name: "index_room_call_modules_on_room_module_id"
  end

  create_table "room_call_price_modules", id: :serial, force: :cascade do |t|
    t.integer "room_call_price_id"
    t.integer "room_module_id"
    t.index ["room_call_price_id"], name: "index_room_call_price_modules_on_room_call_price_id"
    t.index ["room_module_id"], name: "index_room_call_price_modules_on_room_module_id"
  end

  create_table "room_call_prices", id: :serial, force: :cascade do |t|
    t.integer "room_call_id"
    t.string "name"
    t.text "description"
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "features"
    t.index ["room_call_id"], name: "index_room_call_prices_on_room_call_id"
  end

  create_table "room_call_submission_fields", id: :serial, force: :cascade do |t|
    t.integer "room_call_submission_id"
    t.integer "room_call_field_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_call_field_id"], name: "index_room_call_submission_fields_on_room_call_field_id"
    t.index ["room_call_submission_id"], name: "index_room_call_submission_fields_on_room_call_submission_id"
  end

  create_table "room_call_submissions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "room_call_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.string "website"
    t.index ["room_call_id"], name: "index_room_call_submissions_on_room_call_id"
    t.index ["user_id"], name: "index_room_call_submissions_on_user_id"
  end

  create_table "room_calls", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.date "starts_at"
    t.date "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subtitle"
    t.text "about_us"
    t.text "about_partner"
    t.date "opens_at"
    t.string "slug"
    t.integer "total_vacancies", default: 0
    t.integer "graetzl_id"
    t.integer "district_id"
    t.integer "user_id"
    t.integer "location_id"
    t.string "first_name"
    t.string "last_name"
    t.string "website"
    t.string "email"
    t.string "phone"
    t.string "avatar_id"
    t.string "avatar_content_type"
    t.string "cover_photo_id"
    t.string "cover_photo_content_type"
    t.integer "address_id"
    t.jsonb "cover_photo_data"
    t.jsonb "avatar_data"
    t.string "region_id"
    t.string "address_street"
    t.string "address_zip"
    t.string "address_city"
    t.geometry "address_coordinates", limit: {:srid=>0, :type=>"geometry"}
    t.string "address_description"
    t.index ["address_id"], name: "index_room_calls_on_address_id"
    t.index ["district_id"], name: "index_room_calls_on_district_id"
    t.index ["graetzl_id"], name: "index_room_calls_on_graetzl_id"
    t.index ["location_id"], name: "index_room_calls_on_location_id"
    t.index ["region_id"], name: "index_room_calls_on_region_id"
    t.index ["user_id"], name: "index_room_calls_on_user_id"
  end

  create_table "room_categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "main_photo_id"
    t.string "main_photo_content_type"
    t.integer "position", default: 0
    t.string "css_ico_class"
    t.jsonb "main_photo_data"
    t.string "slug"
    t.index ["slug"], name: "index_room_categories_on_slug", unique: true
  end

  create_table "room_demand_categories", id: :serial, force: :cascade do |t|
    t.integer "room_category_id"
    t.integer "room_demand_id"
    t.index ["room_category_id"], name: "index_room_demand_categories_on_room_category_id"
    t.index ["room_demand_id"], name: "index_room_demand_categories_on_room_demand_id"
  end

  create_table "room_demand_graetzls", id: :serial, force: :cascade do |t|
    t.integer "graetzl_id"
    t.integer "room_demand_id"
    t.index ["graetzl_id"], name: "index_room_demand_graetzls_on_graetzl_id"
    t.index ["room_demand_id"], name: "index_room_demand_graetzls_on_room_demand_id"
  end

  create_table "room_demands", id: :serial, force: :cascade do |t|
    t.string "slogan"
    t.decimal "needed_area", precision: 10, scale: 2
    t.text "demand_description"
    t.text "personal_description"
    t.boolean "wants_collaboration"
    t.string "slug"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "demand_type", default: 0
    t.string "first_name"
    t.string "last_name"
    t.string "website"
    t.string "email"
    t.string "phone"
    t.integer "location_id"
    t.string "avatar_id"
    t.string "avatar_content_type"
    t.integer "status", default: 0
    t.date "last_activated_at"
    t.jsonb "avatar_data"
    t.string "region_id"
    t.index ["location_id"], name: "index_room_demands_on_location_id"
    t.index ["region_id"], name: "index_room_demands_on_region_id"
    t.index ["user_id"], name: "index_room_demands_on_user_id"
  end

  create_table "room_modules", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "icon"
  end

  create_table "room_offer_availabilities", force: :cascade do |t|
    t.bigint "room_offer_id"
    t.integer "day_0_from"
    t.integer "day_0_to"
    t.integer "day_1_from"
    t.integer "day_1_to"
    t.integer "day_2_from"
    t.integer "day_2_to"
    t.integer "day_3_from"
    t.integer "day_3_to"
    t.integer "day_4_from"
    t.integer "day_4_to"
    t.integer "day_5_from"
    t.integer "day_5_to"
    t.integer "day_6_from"
    t.integer "day_6_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_offer_id"], name: "index_room_offer_availabilities_on_room_offer_id"
  end

  create_table "room_offer_categories", id: :serial, force: :cascade do |t|
    t.integer "room_category_id"
    t.integer "room_offer_id"
    t.index ["room_category_id"], name: "index_room_offer_categories_on_room_category_id"
    t.index ["room_offer_id"], name: "index_room_offer_categories_on_room_offer_id"
  end

  create_table "room_offer_prices", id: :serial, force: :cascade do |t|
    t.integer "room_offer_id"
    t.string "name"
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_offer_id"], name: "index_room_offer_prices_on_room_offer_id"
  end

  create_table "room_offer_waiting_users", id: :serial, force: :cascade do |t|
    t.integer "room_offer_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_offer_id"], name: "index_room_offer_waiting_users_on_room_offer_id"
    t.index ["user_id"], name: "index_room_offer_waiting_users_on_user_id"
  end

  create_table "room_offers", id: :serial, force: :cascade do |t|
    t.string "slogan"
    t.text "room_description"
    t.decimal "total_area", precision: 10, scale: 2
    t.decimal "rented_area", precision: 10, scale: 2
    t.text "owner_description"
    t.text "tenant_description"
    t.boolean "wants_collaboration"
    t.string "slug"
    t.integer "user_id"
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "graetzl_id"
    t.integer "district_id"
    t.string "cover_photo_id"
    t.string "cover_photo_content_type"
    t.integer "offer_type", default: 0
    t.string "first_name"
    t.string "last_name"
    t.string "website"
    t.string "email"
    t.string "phone"
    t.string "avatar_id"
    t.string "avatar_content_type"
    t.integer "status", default: 0
    t.date "last_activated_at"
    t.boolean "rental_enabled", default: false
    t.integer "address_id"
    t.jsonb "cover_photo_data"
    t.jsonb "avatar_data"
    t.string "region_id"
    t.string "address_street"
    t.string "address_zip"
    t.string "address_city"
    t.geometry "address_coordinates", limit: {:srid=>0, :type=>"geometry"}
    t.string "address_description"
    t.index ["address_id"], name: "index_room_offers_on_address_id"
    t.index ["district_id"], name: "index_room_offers_on_district_id"
    t.index ["graetzl_id"], name: "index_room_offers_on_graetzl_id"
    t.index ["location_id"], name: "index_room_offers_on_location_id"
    t.index ["region_id"], name: "index_room_offers_on_region_id"
    t.index ["user_id"], name: "index_room_offers_on_user_id"
  end

  create_table "room_rental_prices", force: :cascade do |t|
    t.integer "room_offer_id"
    t.string "name"
    t.decimal "price_per_hour", precision: 10, scale: 2
    t.integer "minimum_rental_hours", default: 0
    t.integer "four_hour_discount", default: 0
    t.integer "eight_hour_discount", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "room_rental_slots", force: :cascade do |t|
    t.bigint "room_rental_id"
    t.date "rent_date"
    t.integer "hour_from", null: false
    t.integer "hour_to", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_rental_id"], name: "index_room_rental_slots_on_room_rental_id"
  end

  create_table "room_rentals", force: :cascade do |t|
    t.bigint "room_offer_id"
    t.bigint "user_id"
    t.string "renter_company"
    t.string "renter_name"
    t.string "renter_address"
    t.string "renter_zip"
    t.string "renter_city"
    t.integer "rental_status", default: 0
    t.integer "payment_status", default: 0
    t.string "payment_method"
    t.decimal "hourly_price", precision: 10, scale: 2, default: "0.0"
    t.decimal "basic_price", precision: 10, scale: 2, default: "0.0"
    t.decimal "discount", precision: 10, scale: 2, default: "0.0"
    t.decimal "service_fee", precision: 10, scale: 2, default: "0.0"
    t.decimal "tax", precision: 10, scale: 2, default: "0.0"
    t.string "stripe_source_id"
    t.string "stripe_charge_id"
    t.string "stripe_payment_intent_id"
    t.string "invoice_number"
    t.integer "owner_rating"
    t.integer "renter_rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payment_card_last4"
    t.string "region_id"
    t.index ["region_id"], name: "index_room_rentals_on_region_id"
    t.index ["room_offer_id"], name: "index_room_rentals_on_room_offer_id"
    t.index ["stripe_payment_intent_id"], name: "index_room_rentals_on_stripe_payment_intent_id"
    t.index ["user_id"], name: "index_room_rentals_on_user_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "tool_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "main_photo_id"
    t.string "main_photo_content_type"
    t.integer "position", default: 0
    t.jsonb "main_photo_data"
    t.string "slug"
    t.string "icon"
    t.index ["slug"], name: "index_tool_categories_on_slug", unique: true
  end

  create_table "tool_demand_graetzls", force: :cascade do |t|
    t.bigint "tool_demand_id"
    t.bigint "graetzl_id"
    t.index ["graetzl_id"], name: "index_tool_demand_graetzls_on_graetzl_id"
    t.index ["tool_demand_id"], name: "index_tool_demand_graetzls_on_tool_demand_id"
  end

  create_table "tool_demands", force: :cascade do |t|
    t.string "slogan"
    t.text "demand_description"
    t.text "usage_description"
    t.string "slug"
    t.string "first_name"
    t.string "last_name"
    t.string "website"
    t.string "email"
    t.string "phone"
    t.integer "status", default: 0
    t.string "region_id"
    t.date "last_activated_at"
    t.boolean "usage_period", default: false
    t.date "usage_period_from"
    t.date "usage_period_to"
    t.integer "usage_days"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.bigint "location_id"
    t.bigint "tool_category_id"
    t.decimal "budget", precision: 10, scale: 2
    t.index ["location_id"], name: "index_tool_demands_on_location_id"
    t.index ["region_id"], name: "index_tool_demands_on_region_id"
    t.index ["slug"], name: "index_tool_demands_on_slug"
    t.index ["tool_category_id"], name: "index_tool_demands_on_tool_category_id"
    t.index ["user_id"], name: "index_tool_demands_on_user_id"
  end

  create_table "tool_offers", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.text "description"
    t.string "brand"
    t.string "model"
    t.string "cover_photo_id"
    t.string "cover_photo_content_type"
    t.bigint "tool_category_id"
    t.integer "tool_subcategory_id"
    t.bigint "user_id"
    t.bigint "location_id"
    t.bigint "graetzl_id"
    t.integer "value_up_to"
    t.string "serial_number"
    t.text "known_defects"
    t.decimal "price_per_day", precision: 10, scale: 2
    t.integer "two_day_discount", default: 0
    t.integer "weekly_discount", default: 0
    t.integer "status", default: 0
    t.string "first_name"
    t.string "last_name"
    t.string "iban"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "address_id"
    t.jsonb "cover_photo_data"
    t.string "region_id"
    t.decimal "deposit", precision: 10, scale: 2
    t.string "address_street"
    t.string "address_zip"
    t.string "address_city"
    t.geometry "address_coordinates", limit: {:srid=>0, :type=>"geometry"}
    t.string "address_description"
    t.index ["address_id"], name: "index_tool_offers_on_address_id"
    t.index ["graetzl_id"], name: "index_tool_offers_on_graetzl_id"
    t.index ["location_id"], name: "index_tool_offers_on_location_id"
    t.index ["region_id"], name: "index_tool_offers_on_region_id"
    t.index ["status"], name: "index_tool_offers_on_status"
    t.index ["tool_category_id"], name: "index_tool_offers_on_tool_category_id"
    t.index ["tool_subcategory_id"], name: "index_tool_offers_on_tool_subcategory_id"
    t.index ["user_id"], name: "index_tool_offers_on_user_id"
  end

  create_table "tool_rentals", force: :cascade do |t|
    t.bigint "tool_offer_id"
    t.bigint "user_id"
    t.date "rent_from"
    t.date "rent_to"
    t.string "renter_company"
    t.string "renter_name"
    t.string "renter_address"
    t.string "renter_zip"
    t.string "renter_city"
    t.integer "rental_status", default: 0
    t.string "stripe_payment_intent_id"
    t.integer "owner_rating"
    t.integer "renter_rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payment_method"
    t.decimal "basic_price", precision: 10, scale: 2, default: "0.0"
    t.decimal "discount", precision: 10, scale: 2, default: "0.0"
    t.decimal "service_fee", precision: 10, scale: 2, default: "0.0"
    t.decimal "insurance_fee", precision: 10, scale: 2, default: "0.0"
    t.integer "payment_status", default: 0
    t.string "stripe_source_id"
    t.string "stripe_charge_id"
    t.decimal "tax", precision: 10, scale: 2, default: "0.0"
    t.string "invoice_number"
    t.decimal "daily_price", precision: 10, scale: 2, default: "0.0"
    t.string "payment_card_last4"
    t.string "region_id"
    t.index ["region_id"], name: "index_tool_rentals_on_region_id"
    t.index ["stripe_payment_intent_id"], name: "index_tool_rentals_on_stripe_payment_intent_id"
    t.index ["tool_offer_id"], name: "index_tool_rentals_on_tool_offer_id"
    t.index ["user_id"], name: "index_tool_rentals_on_user_id"
  end

  create_table "user_graetzls", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "graetzl_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["graetzl_id"], name: "index_user_graetzls_on_graetzl_id"
    t.index ["user_id"], name: "index_user_graetzls_on_user_id"
  end

  create_table "user_message_thread_members", force: :cascade do |t|
    t.bigint "user_message_thread_id"
    t.bigint "user_id"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "last_message_seen_id", default: 0
    t.index ["user_id"], name: "index_user_message_thread_members_on_user_id"
    t.index ["user_message_thread_id"], name: "index_user_message_thread_members_on_user_message_thread_id"
  end

  create_table "user_message_threads", force: :cascade do |t|
    t.bigint "tool_rental_id"
    t.datetime "last_message_at"
    t.text "last_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "room_rental_id"
    t.integer "thread_type", default: 0
    t.string "user_key"
    t.index ["last_message"], name: "index_user_message_threads_on_last_message"
    t.index ["room_rental_id"], name: "index_user_message_threads_on_room_rental_id"
    t.index ["tool_rental_id"], name: "index_user_message_threads_on_tool_rental_id"
  end

  create_table "user_messages", force: :cascade do |t|
    t.bigint "user_message_thread_id"
    t.bigint "user_id"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_messages_on_user_id"
    t.index ["user_message_thread_id"], name: "index_user_messages_on_user_message_thread_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "username", limit: 255
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.boolean "newsletter", default: false, null: false
    t.integer "graetzl_id"
    t.string "avatar_id"
    t.integer "enabled_website_notifications", default: 0
    t.integer "role"
    t.string "avatar_content_type"
    t.integer "immediate_mail_notifications", default: 0
    t.integer "daily_mail_notifications", default: 0
    t.integer "weekly_mail_notifications", default: 0
    t.string "slug"
    t.string "cover_photo_id"
    t.string "cover_photo_content_type"
    t.text "bio"
    t.string "website"
    t.string "origin"
    t.integer "location_category_id"
    t.boolean "business", default: true
    t.string "stripe_customer_id", limit: 50
    t.string "iban"
    t.decimal "rating", precision: 3, scale: 2
    t.integer "ratings_count", default: 0
    t.integer "address_id"
    t.jsonb "avatar_data"
    t.jsonb "cover_photo_data"
    t.string "region_id"
    t.string "address_street"
    t.string "address_zip"
    t.string "address_city"
    t.geometry "address_coordinates", limit: {:srid=>0, :type=>"geometry"}
    t.string "address_description"
    t.index ["address_id"], name: "index_users_on_address_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["graetzl_id"], name: "index_users_on_graetzl_id"
    t.index ["location_category_id"], name: "index_users_on_location_category_id"
    t.index ["region_id"], name: "index_users_on_region_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id"
  end

  create_table "zuckerls", id: :serial, force: :cascade do |t|
    t.integer "location_id"
    t.string "title"
    t.text "description"
    t.string "image_id"
    t.string "image_content_type"
    t.boolean "flyer", default: false
    t.string "aasm_state"
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.boolean "entire_region", default: false
    t.string "invoice_number"
    t.string "link"
    t.jsonb "cover_photo_data"
    t.string "region_id"
    t.bigint "user_id"
    t.index ["location_id"], name: "index_zuckerls_on_location_id"
    t.index ["region_id"], name: "index_zuckerls_on_region_id"
    t.index ["slug"], name: "index_zuckerls_on_slug"
    t.index ["user_id"], name: "index_zuckerls_on_user_id"
  end

  add_foreign_key "activities", "groups", on_delete: :cascade
  add_foreign_key "activity_graetzls", "activities", on_delete: :cascade
  add_foreign_key "activity_graetzls", "graetzls", on_delete: :cascade
  add_foreign_key "billing_addresses", "users", on_delete: :nullify
  add_foreign_key "business_interests_users", "business_interests", on_delete: :cascade
  add_foreign_key "business_interests_users", "users", on_delete: :cascade
  add_foreign_key "coop_demand_graetzls", "coop_demands", on_delete: :cascade
  add_foreign_key "coop_demand_graetzls", "graetzls", on_delete: :cascade
  add_foreign_key "coop_demands", "coop_demand_categories", on_delete: :nullify
  add_foreign_key "coop_demands", "locations", on_delete: :nullify
  add_foreign_key "coop_demands", "users", on_delete: :cascade
  add_foreign_key "coop_suggested_tags", "coop_demand_categories", on_delete: :nullify
  add_foreign_key "crowd_campaign_posts", "crowd_campaigns", on_delete: :cascade
  add_foreign_key "crowd_campaign_posts", "graetzls", on_delete: :nullify
  add_foreign_key "crowd_campaigns", "graetzls", on_delete: :nullify
  add_foreign_key "crowd_campaigns", "locations", on_delete: :nullify
  add_foreign_key "crowd_campaigns", "room_offers", on_delete: :nullify
  add_foreign_key "crowd_campaigns", "users", on_delete: :cascade
  add_foreign_key "crowd_donation_pledges", "crowd_campaigns", on_delete: :nullify
  add_foreign_key "crowd_donation_pledges", "crowd_donations", on_delete: :nullify
  add_foreign_key "crowd_donation_pledges", "users", on_delete: :nullify
  add_foreign_key "crowd_donations", "crowd_campaigns", on_delete: :cascade
  add_foreign_key "crowd_pledges", "crowd_campaigns", on_delete: :nullify
  add_foreign_key "crowd_pledges", "crowd_rewards", on_delete: :nullify
  add_foreign_key "crowd_pledges", "users", on_delete: :nullify
  add_foreign_key "crowd_rewards", "crowd_campaigns", on_delete: :cascade
  add_foreign_key "discussion_categories", "groups", on_delete: :cascade
  add_foreign_key "discussion_followings", "discussions", on_delete: :cascade
  add_foreign_key "discussion_followings", "users", on_delete: :cascade
  add_foreign_key "discussion_posts", "discussions", on_delete: :cascade
  add_foreign_key "discussion_posts", "users", on_delete: :nullify
  add_foreign_key "discussions", "discussion_categories", on_delete: :nullify
  add_foreign_key "discussions", "groups", on_delete: :cascade
  add_foreign_key "district_graetzls", "districts", on_delete: :cascade
  add_foreign_key "district_graetzls", "graetzls", on_delete: :cascade
  add_foreign_key "going_tos", "meeting_additional_dates", on_delete: :nullify
  add_foreign_key "group_graetzls", "graetzls", on_delete: :cascade
  add_foreign_key "group_graetzls", "groups", on_delete: :cascade
  add_foreign_key "group_join_questions", "groups", on_delete: :cascade
  add_foreign_key "group_join_requests", "groups", on_delete: :cascade
  add_foreign_key "group_join_requests", "users", on_delete: :cascade
  add_foreign_key "group_users", "groups", on_delete: :cascade
  add_foreign_key "group_users", "users", on_delete: :cascade
  add_foreign_key "groups", "locations", on_delete: :nullify
  add_foreign_key "groups", "room_calls", on_delete: :nullify
  add_foreign_key "groups", "room_demands", on_delete: :nullify
  add_foreign_key "groups", "room_offers", on_delete: :nullify
  add_foreign_key "location_menus", "graetzls", on_delete: :nullify
  add_foreign_key "location_menus", "locations", on_delete: :cascade
  add_foreign_key "meeting_additional_dates", "meetings", on_delete: :cascade
  add_foreign_key "meetings", "groups", on_delete: :nullify
  add_foreign_key "meetings", "users", on_delete: :nullify
  add_foreign_key "room_call_fields", "room_calls", on_delete: :cascade
  add_foreign_key "room_call_modules", "room_calls", on_delete: :cascade
  add_foreign_key "room_call_modules", "room_modules", on_delete: :cascade
  add_foreign_key "room_call_price_modules", "room_call_prices", on_delete: :cascade
  add_foreign_key "room_call_price_modules", "room_modules", on_delete: :cascade
  add_foreign_key "room_call_prices", "room_calls", on_delete: :cascade
  add_foreign_key "room_call_submission_fields", "room_call_fields", on_delete: :cascade
  add_foreign_key "room_call_submission_fields", "room_call_submissions", on_delete: :cascade
  add_foreign_key "room_call_submissions", "room_calls", on_delete: :cascade
  add_foreign_key "room_call_submissions", "users", on_delete: :nullify
  add_foreign_key "room_calls", "districts", on_delete: :nullify
  add_foreign_key "room_calls", "graetzls", on_delete: :nullify
  add_foreign_key "room_calls", "locations", on_delete: :nullify
  add_foreign_key "room_calls", "users", on_delete: :nullify
  add_foreign_key "room_demand_categories", "room_categories", on_delete: :cascade
  add_foreign_key "room_demand_categories", "room_demands", on_delete: :cascade
  add_foreign_key "room_demand_graetzls", "graetzls", on_delete: :cascade
  add_foreign_key "room_demand_graetzls", "room_demands", on_delete: :cascade
  add_foreign_key "room_demands", "locations", on_delete: :nullify
  add_foreign_key "room_demands", "users", on_delete: :cascade
  add_foreign_key "room_offer_availabilities", "room_offers", on_delete: :cascade
  add_foreign_key "room_offer_categories", "room_categories", on_delete: :cascade
  add_foreign_key "room_offer_categories", "room_offers", on_delete: :cascade
  add_foreign_key "room_offer_prices", "room_offers", on_delete: :cascade
  add_foreign_key "room_offer_waiting_users", "room_offers", on_delete: :cascade
  add_foreign_key "room_offer_waiting_users", "users", on_delete: :cascade
  add_foreign_key "room_offers", "districts", on_delete: :nullify
  add_foreign_key "room_offers", "graetzls", on_delete: :nullify
  add_foreign_key "room_offers", "locations", on_delete: :nullify
  add_foreign_key "room_offers", "users", on_delete: :cascade
  add_foreign_key "room_rental_slots", "room_rentals", on_delete: :cascade
  add_foreign_key "room_rentals", "room_offers", on_delete: :nullify
  add_foreign_key "room_rentals", "users", on_delete: :nullify
  add_foreign_key "tool_demand_graetzls", "graetzls", on_delete: :cascade
  add_foreign_key "tool_demand_graetzls", "tool_demands", on_delete: :cascade
  add_foreign_key "tool_demands", "locations", on_delete: :nullify
  add_foreign_key "tool_demands", "tool_categories", on_delete: :nullify
  add_foreign_key "tool_demands", "users", on_delete: :cascade
  add_foreign_key "tool_offers", "graetzls", on_delete: :nullify
  add_foreign_key "tool_offers", "locations", on_delete: :nullify
  add_foreign_key "tool_offers", "tool_categories", on_delete: :nullify
  add_foreign_key "tool_offers", "users", on_delete: :cascade
  add_foreign_key "tool_rentals", "tool_offers", on_delete: :nullify
  add_foreign_key "tool_rentals", "users", on_delete: :nullify
  add_foreign_key "user_graetzls", "graetzls", on_delete: :cascade
  add_foreign_key "user_graetzls", "users", on_delete: :cascade
  add_foreign_key "user_message_thread_members", "user_message_threads", on_delete: :cascade
  add_foreign_key "user_message_thread_members", "users", on_delete: :cascade
  add_foreign_key "user_message_threads", "room_rentals", on_delete: :nullify
  add_foreign_key "user_message_threads", "tool_rentals", on_delete: :nullify
  add_foreign_key "user_messages", "user_message_threads", on_delete: :cascade
  add_foreign_key "user_messages", "users", on_delete: :cascade
  add_foreign_key "users", "location_categories", on_delete: :nullify
  add_foreign_key "zuckerls", "users", on_delete: :nullify
end
