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

ActiveRecord::Schema[7.2].define(version: 2025_10_02_190000) do
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
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "activities", id: :serial, force: :cascade do |t|
    t.integer "subject_id"
    t.string "subject_type", limit: 255
    t.string "child_id"
    t.string "child_type", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "entire_region", default: false
    t.bigint "group_id"
    t.string "region_id"
    t.boolean "entire_platform", default: false, null: false
    t.index ["child_id", "child_type"], name: "index_activities_on_child_id_and_child_type"
    t.index ["group_id"], name: "index_activities_on_group_id"
    t.index ["region_id"], name: "index_activities_on_region_id"
    t.index ["subject_id", "subject_type"], name: "index_activities_on_subject_id_and_subject_type"
  end

  create_table "activity_graetzls", force: :cascade do |t|
    t.bigint "activity_id"
    t.bigint "graetzl_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_activity_graetzls_on_activity_id"
    t.index ["graetzl_id"], name: "index_activity_graetzls_on_graetzl_id"
  end

  create_table "api_accounts", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "api_key"
    t.boolean "enabled", default: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.string "vat_id"
    t.index ["location_id"], name: "index_billing_addresses_on_location_id"
    t.index ["user_id"], name: "index_billing_addresses_on_user_id"
  end

  create_table "business_interests", id: :serial, force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "mailchimp_id"
  end

  create_table "business_interests_users", id: false, force: :cascade do |t|
    t.integer "business_interest_id"
    t.integer "user_id"
    t.index ["business_interest_id"], name: "index_business_interests_users_on_business_interest_id"
    t.index ["user_id"], name: "index_business_interests_users_on_user_id"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "user_id"
    t.integer "commentable_id"
    t.string "commentable_type", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "contact_list_entries", force: :cascade do |t|
    t.string "name"
    t.string "email", default: "", null: false
    t.string "phone"
    t.string "region_id"
    t.string "via_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "message"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_contact_list_entries_on_user_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "location_id"
    t.bigint "coop_demand_category_id"
    t.integer "coop_type", default: 0
    t.boolean "entire_region", default: false, null: false
    t.index ["coop_demand_category_id"], name: "index_coop_demands_on_coop_demand_category_id"
    t.index ["location_id"], name: "index_coop_demands_on_location_id"
    t.index ["region_id"], name: "index_coop_demands_on_region_id"
    t.index ["slug"], name: "index_coop_demands_on_slug"
    t.index ["user_id"], name: "index_coop_demands_on_user_id"
  end

  create_table "coop_suggested_tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "coop_demand_category_id"
    t.index ["coop_demand_category_id"], name: "index_coop_suggested_tags_on_coop_demand_category_id"
  end

  create_table "coupon_histories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "coupon_id"
    t.string "stripe_id"
    t.datetime "sent_at", precision: nil
    t.datetime "redeemed_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "valid_until", precision: nil
    t.index ["coupon_id"], name: "index_coupon_histories_on_coupon_id"
    t.index ["user_id"], name: "index_coupon_histories_on_user_id"
  end

  create_table "coupons", force: :cascade do |t|
    t.string "code", null: false
    t.string "stripe_id"
    t.decimal "amount_off", precision: 10, scale: 2
    t.integer "percent_off"
    t.string "duration", null: false
    t.datetime "valid_from", precision: nil
    t.datetime "valid_until", precision: nil
    t.string "name"
    t.string "description"
    t.boolean "enabled", default: true
    t.string "region_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_coupons_on_code", unique: true
  end

  create_table "crowd_boost_charges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "payment_status"
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "debited_at", precision: nil
    t.string "contact_name"
    t.string "address_street"
    t.string "address_zip"
    t.string "address_city"
    t.string "email"
    t.string "stripe_customer_id"
    t.string "stripe_payment_method_id"
    t.string "stripe_payment_intent_id"
    t.string "payment_method"
    t.string "payment_card_last4"
    t.string "payment_wallet"
    t.string "region_id"
    t.string "invoice_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "crowd_boost_id"
    t.bigint "user_id"
    t.uuid "crowd_pledge_id"
    t.bigint "zuckerl_id"
    t.string "charge_type", default: "general"
    t.bigint "room_booster_id"
    t.bigint "subscription_invoice_id"
    t.index ["crowd_boost_id"], name: "index_crowd_boost_charges_on_crowd_boost_id"
    t.index ["crowd_pledge_id"], name: "index_crowd_boost_charges_on_crowd_pledge_id"
    t.index ["region_id"], name: "index_crowd_boost_charges_on_region_id"
    t.index ["room_booster_id"], name: "index_crowd_boost_charges_on_room_booster_id"
    t.index ["subscription_invoice_id"], name: "index_crowd_boost_charges_on_subscription_invoice_id"
    t.index ["user_id"], name: "index_crowd_boost_charges_on_user_id"
    t.index ["zuckerl_id"], name: "index_crowd_boost_charges_on_zuckerl_id"
  end

  create_table "crowd_boost_pledges", force: :cascade do |t|
    t.string "status"
    t.decimal "amount", precision: 10, scale: 2
    t.string "region_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "crowd_boost_id"
    t.bigint "crowd_boost_slot_id"
    t.bigint "crowd_campaign_id"
    t.datetime "debited_at", precision: nil
    t.index ["crowd_boost_id"], name: "index_crowd_boost_pledges_on_crowd_boost_id"
    t.index ["crowd_boost_slot_id"], name: "index_crowd_boost_pledges_on_crowd_boost_slot_id"
    t.index ["crowd_campaign_id"], name: "index_crowd_boost_pledges_on_crowd_campaign_id"
    t.index ["region_id"], name: "index_crowd_boost_pledges_on_region_id"
  end

  create_table "crowd_boost_slot_graetzls", force: :cascade do |t|
    t.bigint "crowd_boost_slot_id"
    t.bigint "graetzl_id"
    t.index ["crowd_boost_slot_id"], name: "index_crowd_boost_slot_graetzls_on_crowd_boost_slot_id"
    t.index ["graetzl_id"], name: "index_crowd_boost_slot_graetzls_on_graetzl_id"
  end

  create_table "crowd_boost_slots", force: :cascade do |t|
    t.decimal "slot_amount_limit", precision: 10, scale: 2
    t.date "starts_at"
    t.date "ends_at"
    t.text "slot_description"
    t.text "slot_terms"
    t.integer "threshold_pledge_count", default: 0
    t.decimal "threshold_funding_percentage", precision: 5, scale: 2
    t.decimal "boost_amount", precision: 10, scale: 2
    t.decimal "boost_percentage", precision: 5, scale: 2
    t.decimal "boost_amount_limit", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "crowd_boost_id"
    t.text "slot_detail_description"
    t.text "slot_process_description"
    t.index ["crowd_boost_id"], name: "index_crowd_boost_slots_on_crowd_boost_id"
  end

  create_table "crowd_boosts", force: :cascade do |t|
    t.integer "status", default: 0
    t.text "region_ids", default: [], array: true
    t.string "chargeable_status"
    t.string "slug"
    t.string "title"
    t.string "slogan"
    t.text "description"
    t.jsonb "avatar_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "pledge_charge", default: false, null: false
  end

  create_table "crowd_campaign_posts", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "region_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "graetzl_id"
    t.bigint "location_id"
    t.bigint "room_offer_id"
    t.integer "funding_status", default: 0
    t.jsonb "avatar_data"
    t.text "aim_description"
    t.integer "active_state", default: 0
    t.string "invoice_number"
    t.boolean "crowdfunding_call", default: false
    t.decimal "service_fee_percentage", precision: 5, scale: 2
    t.string "visibility_status"
    t.string "contact_instagram"
    t.string "contact_facebook"
    t.boolean "guest_newsletter", default: true, null: false
    t.string "boost_status"
    t.bigint "crowd_boost_slot_id"
    t.string "vat_id"
    t.datetime "last_activity_at", precision: nil
    t.datetime "payout_attempted_at", precision: nil
    t.datetime "payout_completed_at", precision: nil
    t.string "transfer_status"
    t.string "stripe_payout_transfer_id"
    t.string "newsletter_status", default: "region", null: false
    t.boolean "ending_newsletter", default: false, null: false
    t.boolean "incomplete_newsletter", default: false, null: false
    t.decimal "crowd_pledges_finalized_sum", precision: 10, scale: 2
    t.decimal "crowd_boost_pledges_finalized_sum", precision: 10, scale: 2
    t.integer "pledges_and_donations_finalized_count"
    t.integer "crowd_donation_pledges_count", default: 0, null: false
    t.integer "importance", default: 1, null: false
    t.index ["crowd_boost_slot_id"], name: "index_crowd_campaigns_on_crowd_boost_slot_id"
    t.index ["graetzl_id"], name: "index_crowd_campaigns_on_graetzl_id"
    t.index ["last_activity_at"], name: "index_crowd_campaigns_on_last_activity_at"
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
    t.jsonb "main_photo_data"
    t.string "slug"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_crowd_categories_on_slug"
  end

  create_table "crowd_donation_pledges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "status", default: 0
    t.string "contact_name"
    t.string "region_id"
    t.text "answer"
    t.bigint "crowd_campaign_id"
    t.bigint "crowd_donation_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "claimed", default: 0
    t.index ["crowd_campaign_id"], name: "index_crowd_donations_on_crowd_campaign_id"
  end

  create_table "crowd_pledges", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "status", default: "0"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.boolean "anonym", default: false
    t.decimal "total_price", precision: 10, scale: 2
    t.string "stripe_customer_id"
    t.string "stripe_payment_method_id"
    t.string "stripe_payment_intent_id"
    t.string "payment_method"
    t.string "payment_card_last4"
    t.boolean "terms", default: false
    t.datetime "debited_at", precision: nil
    t.boolean "guest_newsletter", default: false, null: false
    t.datetime "inclomplete_reminder_sent_at", precision: nil
    t.string "payment_wallet"
    t.jsonb "user_agent"
    t.decimal "crowd_boost_charge_amount", precision: 10, scale: 2
    t.bigint "crowd_boost_id"
    t.integer "comment_id"
    t.decimal "total_overall_price", precision: 10, scale: 2
    t.decimal "stripe_fee", precision: 10, scale: 2
    t.datetime "confirmation_sent_at", precision: nil
    t.datetime "authorized_at", precision: nil
    t.datetime "charge_returned_at", precision: nil
    t.datetime "charge_seen_at", precision: nil
    t.datetime "disputed_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "dispute_status"
    t.index ["comment_id"], name: "index_crowd_pledges_on_comment_id"
    t.index ["crowd_boost_id"], name: "index_crowd_pledges_on_crowd_boost_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "claimed", default: 0
    t.integer "status", default: 0
    t.index ["crowd_campaign_id"], name: "index_crowd_rewards_on_crowd_campaign_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "discussion_categories", id: :serial, force: :cascade do |t|
    t.string "title"
    t.integer "group_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["group_id"], name: "index_discussion_categories_on_group_id"
    t.index ["title"], name: "index_discussion_categories_on_title"
  end

  create_table "discussion_default_categories", id: :serial, force: :cascade do |t|
    t.string "title"
  end

  create_table "discussion_followings", id: :serial, force: :cascade do |t|
    t.integer "discussion_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["discussion_id"], name: "index_discussion_followings_on_discussion_id"
    t.index ["user_id"], name: "index_discussion_followings_on_user_id"
  end

  create_table "discussion_posts", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "discussion_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "initial_post", default: false
    t.index ["discussion_id"], name: "index_discussion_posts_on_discussion_id"
    t.index ["user_id"], name: "index_discussion_posts_on_user_id"
  end

  create_table "discussions", id: :serial, force: :cascade do |t|
    t.string "title"
    t.boolean "closed", default: false
    t.boolean "sticky", default: false
    t.integer "group_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.datetime "last_post_at", precision: nil
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
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.geometry "area", limit: {:srid=>0, :type=>"st_polygon"}
    t.string "slug", limit: 255
    t.string "region_id"
    t.index ["region_id"], name: "index_districts_on_region_id"
    t.index ["slug"], name: "index_districts_on_slug"
  end

  create_table "energy_categories", force: :cascade do |t|
    t.string "title"
    t.string "label"
    t.string "group"
    t.string "css_ico_class"
    t.jsonb "main_photo_data"
    t.string "slug"
    t.integer "position", default: 0
    t.boolean "hidden", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_energy_categories_on_slug"
  end

  create_table "energy_demand_categories", force: :cascade do |t|
    t.bigint "energy_demand_id"
    t.bigint "energy_category_id"
    t.index ["energy_category_id"], name: "index_energy_demand_categories_on_energy_category_id"
    t.index ["energy_demand_id"], name: "index_energy_demand_categories_on_energy_demand_id"
  end

  create_table "energy_demand_graetzls", force: :cascade do |t|
    t.bigint "energy_demand_id"
    t.bigint "graetzl_id"
    t.index ["energy_demand_id"], name: "index_energy_demand_graetzls_on_energy_demand_id"
    t.index ["graetzl_id"], name: "index_energy_demand_graetzls_on_graetzl_id"
  end

  create_table "energy_demands", force: :cascade do |t|
    t.integer "status", default: 0
    t.string "slug"
    t.string "energy_type"
    t.string "organization_form"
    t.string "title"
    t.text "description"
    t.boolean "goal_producer_solarpower", default: false
    t.boolean "goal_prosumer_solarpower", default: false
    t.boolean "goal_producer_windpower", default: false
    t.boolean "goal_prosumer_windpower", default: false
    t.boolean "goal_producer_hydropower", default: false
    t.boolean "goal_prosumer_hydropower", default: false
    t.boolean "goal_roofspace", default: false
    t.boolean "goal_freespace", default: false
    t.string "goal_producer_solarpower_kwp"
    t.string "goal_prosumer_solarpower_kwp"
    t.string "goal_roofspace_m2"
    t.string "goal_roofspace_direction"
    t.string "goal_freespace_m2"
    t.string "region_id"
    t.date "last_activated_at"
    t.jsonb "avatar_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "contact_name"
    t.string "contact_website"
    t.string "contact_email"
    t.string "contact_phone"
    t.string "contact_address"
    t.string "contact_zip"
    t.string "contact_city"
    t.string "orientation_type"
    t.index ["region_id"], name: "index_energy_demands_on_region_id"
    t.index ["slug"], name: "index_energy_demands_on_slug"
    t.index ["user_id"], name: "index_energy_demands_on_user_id"
  end

  create_table "energy_offer_categories", force: :cascade do |t|
    t.bigint "energy_offer_id"
    t.bigint "energy_category_id"
    t.index ["energy_category_id"], name: "index_energy_offer_categories_on_energy_category_id"
    t.index ["energy_offer_id"], name: "index_energy_offer_categories_on_energy_offer_id"
  end

  create_table "energy_offer_graetzls", force: :cascade do |t|
    t.bigint "energy_offer_id"
    t.bigint "graetzl_id"
    t.index ["energy_offer_id"], name: "index_energy_offer_graetzls_on_energy_offer_id"
    t.index ["graetzl_id"], name: "index_energy_offer_graetzls_on_graetzl_id"
  end

  create_table "energy_offers", force: :cascade do |t|
    t.integer "status", default: 0
    t.string "slug"
    t.string "energy_type"
    t.string "operation_state"
    t.string "organization_form"
    t.string "title"
    t.text "description"
    t.text "project_goals"
    t.text "special_orientation"
    t.string "members_count"
    t.decimal "producer_price_per_kwh", precision: 10, scale: 2
    t.boolean "goal_producer_solarpower", default: false
    t.boolean "goal_prosumer_solarpower", default: false
    t.boolean "goal_producer_windpower", default: false
    t.boolean "goal_prosumer_windpower", default: false
    t.boolean "goal_producer_hydropower", default: false
    t.boolean "goal_prosumer_hydropower", default: false
    t.boolean "goal_roofspace", default: false
    t.boolean "goal_freespace", default: false
    t.string "goal_producer_solarpower_kwp"
    t.string "goal_prosumer_solarpower_kwp"
    t.string "goal_roofspace_m2"
    t.string "goal_roofspace_direction"
    t.string "goal_freespace_m2"
    t.string "region_id"
    t.date "last_activated_at"
    t.jsonb "cover_photo_data"
    t.jsonb "avatar_data"
    t.string "contact_company"
    t.string "contact_name"
    t.string "contact_address"
    t.string "contact_zip"
    t.string "contact_city"
    t.string "contact_website"
    t.string "contact_email"
    t.string "contact_phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "location_id"
    t.bigint "user_id"
    t.decimal "consumer_price_per_kwh", precision: 10, scale: 2
    t.index ["location_id"], name: "index_energy_offers_on_location_id"
    t.index ["region_id"], name: "index_energy_offers_on_region_id"
    t.index ["slug"], name: "index_energy_offers_on_slug"
    t.index ["user_id"], name: "index_energy_offers_on_user_id"
  end

  create_table "event_categories", force: :cascade do |t|
    t.string "title"
    t.string "css_ico_class"
    t.integer "position", default: 0
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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

  create_table "favorites", force: :cascade do |t|
    t.string "favoritable_type", limit: 255
    t.bigint "favoritable_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["favoritable_type", "favoritable_id"], name: "index_favorites_on_favoritable"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", limit: 255, null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope", limit: 255
    t.datetime "created_at", precision: nil
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "going_tos", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "meeting_id"
    t.integer "role", default: 0
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.bigint "meeting_additional_date_id"
    t.date "going_to_date"
    t.time "going_to_time"
    t.index ["meeting_additional_date_id"], name: "index_going_tos_on_meeting_additional_date_id"
    t.index ["meeting_id"], name: "index_going_tos_on_meeting_id"
    t.index ["user_id"], name: "index_going_tos_on_user_id"
  end

  create_table "graetzls", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.geometry "area", limit: {:srid=>0, :type=>"st_polygon"}
    t.string "slug", limit: 255
    t.integer "users_count", default: 0
    t.string "region_id"
    t.string "zip"
    t.boolean "neighborless", default: false
    t.index ["region_id"], name: "index_graetzls_on_region_id"
    t.index ["slug"], name: "index_graetzls_on_slug"
  end

  create_table "group_categories", id: :serial, force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["group_id"], name: "index_group_join_questions_on_group_id"
  end

  create_table "group_join_requests", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "role", default: 0
    t.datetime "last_activity_at", precision: nil
    t.index ["group_id"], name: "index_group_users_on_group_id"
    t.index ["user_id"], name: "index_group_users_on_user_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "room_offer_id"
    t.boolean "private", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "room_demand_id"
    t.integer "location_id"
    t.boolean "featured", default: false
    t.boolean "hidden", default: false
    t.text "welcome_message"
    t.boolean "default_joined", default: false
    t.integer "group_users_count"
    t.jsonb "cover_photo_data"
    t.string "region_id"
    t.index ["location_id"], name: "index_groups_on_location_id"
    t.index ["region_id"], name: "index_groups_on_region_id"
    t.index ["room_demand_id"], name: "index_groups_on_room_demand_id"
    t.index ["room_offer_id"], name: "index_groups_on_room_offer_id"
  end

  create_table "images", id: :serial, force: :cascade do |t|
    t.integer "imageable_id"
    t.string "imageable_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.jsonb "file_data"
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id"
  end

  create_table "location_categories", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "icon"
    t.integer "position", default: 0
    t.jsonb "main_photo_data"
    t.string "slug"
    t.boolean "hidden", default: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "location_id"
    t.bigint "graetzl_id"
    t.index ["graetzl_id"], name: "index_location_menus_on_graetzl_id"
    t.index ["location_id"], name: "index_location_menus_on_location_id"
    t.index ["region_id"], name: "index_location_menus_on_region_id"
  end

  create_table "location_posts", id: :serial, force: :cascade do |t|
    t.text "content"
    t.integer "graetzl_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
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
    t.string "slug"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "graetzl_id"
    t.integer "state", default: 0
    t.integer "location_category_id"
    t.datetime "last_activity_at", precision: nil
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
    t.boolean "verified", default: false, null: false
    t.boolean "entire_region", default: false, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["meeting_id", "starts_at_date"], name: "idx_meeting_additional_dates_meeting_id_starts_at_date"
    t.index ["meeting_id"], name: "index_meeting_additional_dates_on_meeting_id"
    t.index ["starts_at_date"], name: "idx_meeting_additional_dates_starts_at_date"
  end

  create_table "meetings", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.text "description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "slug", limit: 255
    t.date "starts_at_date"
    t.date "ends_at_date"
    t.time "starts_at_time"
    t.time "ends_at_time"
    t.integer "graetzl_id"
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
    t.date "last_activated_at"
    t.bigint "poll_id"
    t.boolean "entire_region", default: false, null: false
    t.integer "max_going_tos"
    t.integer "meeting_additional_dates_count", default: 0, null: false
    t.index ["address_id"], name: "index_meetings_on_address_id"
    t.index ["created_at"], name: "index_meetings_on_created_at"
    t.index ["graetzl_id"], name: "index_meetings_on_graetzl_id"
    t.index ["group_id"], name: "index_meetings_on_group_id"
    t.index ["location_id"], name: "index_meetings_on_location_id"
    t.index ["poll_id"], name: "index_meetings_on_poll_id"
    t.index ["region_id"], name: "index_meetings_on_region_id"
    t.index ["slug"], name: "index_meetings_on_slug"
    t.index ["starts_at_date"], name: "idx_meetings_starts_at_date"
    t.index ["user_id"], name: "index_meetings_on_user_id"
  end

  create_table "neighbour_graetzls", force: :cascade do |t|
    t.integer "graetzl_id", null: false
    t.integer "neighbour_graetzl_id", null: false
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "bitmask", null: false
    t.boolean "seen", default: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
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
    t.date "sort_date"
    t.date "daily_send_at"
    t.date "weekly_send_at"
    t.bigint "graetzl_id"
    t.integer "owner_id"
    t.index ["child_type", "child_id"], name: "index_notifications_on_child_type_and_child_id"
    t.index ["graetzl_id"], name: "index_notifications_on_graetzl_id"
    t.index ["owner_id"], name: "index_notifications_on_owner_id"
    t.index ["region_id"], name: "index_notifications_on_region_id"
    t.index ["subject_type", "subject_id"], name: "index_notifications_on_subject_type_and_subject_id"
    t.index ["user_id", "notify_at"], name: "index_notifications_on_user_id_and_notify_at"
  end

  create_table "poll_graetzls", force: :cascade do |t|
    t.bigint "poll_id"
    t.bigint "graetzl_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["graetzl_id"], name: "index_poll_graetzls_on_graetzl_id"
    t.index ["poll_id"], name: "index_poll_graetzls_on_poll_id"
  end

  create_table "poll_options", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "poll_question_id"
    t.integer "votes_count", default: 0
    t.index ["poll_question_id"], name: "index_poll_options_on_poll_question_id"
  end

  create_table "poll_questions", force: :cascade do |t|
    t.string "option_type", default: "0"
    t.string "title"
    t.text "description"
    t.boolean "required", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "poll_id"
    t.boolean "main_question", default: false
    t.integer "votes_count", default: 0
    t.integer "position", default: 0
    t.index ["poll_id"], name: "index_poll_questions_on_poll_id"
  end

  create_table "poll_user_answers", force: :cascade do |t|
    t.text "answer"
    t.bigint "poll_question_id"
    t.bigint "poll_option_id"
    t.bigint "poll_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "public_comment", default: false, null: false
    t.index ["poll_option_id"], name: "index_poll_user_answers_on_poll_option_id"
    t.index ["poll_question_id"], name: "index_poll_user_answers_on_poll_question_id"
    t.index ["poll_user_id"], name: "index_poll_user_answers_on_poll_user_id"
  end

  create_table "poll_users", force: :cascade do |t|
    t.text "answer"
    t.bigint "poll_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["poll_id"], name: "index_poll_users_on_poll_id"
    t.index ["user_id"], name: "index_poll_users_on_user_id"
  end

  create_table "polls", force: :cascade do |t|
    t.string "status", default: "0"
    t.string "poll_type", default: "0"
    t.string "slug"
    t.string "title"
    t.text "description"
    t.string "region_id"
    t.jsonb "cover_photo_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.boolean "public_result", default: false
    t.boolean "closed", default: false
    t.string "zip"
    t.datetime "last_activity_at", precision: nil
    t.boolean "comments_enabled", default: true, null: false
    t.index ["region_id"], name: "index_polls_on_region_id"
    t.index ["slug"], name: "index_polls_on_slug"
    t.index ["user_id"], name: "index_polls_on_user_id"
  end

  create_table "region_calls", force: :cascade do |t|
    t.integer "region_type", default: 0
    t.string "region_id"
    t.string "gemeinden"
    t.string "name"
    t.string "personal_position"
    t.string "email", default: "", null: false
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "message"
  end

  create_table "room_boosters", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.string "status", default: "0"
    t.string "payment_status"
    t.string "invoice_number"
    t.string "payment_method"
    t.string "payment_card_last4"
    t.string "stripe_payment_method_id"
    t.string "stripe_payment_intent_id"
    t.string "company"
    t.string "name"
    t.string "address"
    t.string "zip"
    t.string "city"
    t.string "region_id"
    t.datetime "debited_at", precision: nil
    t.date "send_at_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "room_offer_id"
    t.date "starts_at_date"
    t.date "ends_at_date"
    t.string "payment_wallet"
    t.decimal "crowd_boost_charge_amount", precision: 10, scale: 2
    t.bigint "crowd_boost_id"
    t.index ["crowd_boost_id"], name: "index_room_boosters_on_crowd_boost_id"
    t.index ["region_id"], name: "index_room_boosters_on_region_id"
    t.index ["room_offer_id"], name: "index_room_boosters_on_room_offer_id"
    t.index ["user_id"], name: "index_room_boosters_on_user_id"
  end

  create_table "room_categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "demand_type", default: 0
    t.string "first_name"
    t.string "last_name"
    t.string "website"
    t.string "email"
    t.string "phone"
    t.integer "location_id"
    t.integer "status", default: 0
    t.date "last_activated_at"
    t.jsonb "avatar_data"
    t.string "region_id"
    t.boolean "entire_region", default: false, null: false
    t.index ["location_id"], name: "index_room_demands_on_location_id"
    t.index ["region_id"], name: "index_room_demands_on_region_id"
    t.index ["user_id"], name: "index_room_demands_on_user_id"
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["room_offer_id"], name: "index_room_offer_prices_on_room_offer_id"
  end

  create_table "room_offer_waiting_users", id: :serial, force: :cascade do |t|
    t.integer "room_offer_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "graetzl_id"
    t.integer "district_id"
    t.integer "offer_type", default: 0
    t.string "first_name"
    t.string "last_name"
    t.string "website"
    t.string "email"
    t.string "phone"
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
    t.boolean "boosted", default: false
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "room_rental_slots", force: :cascade do |t|
    t.bigint "room_rental_id"
    t.date "rent_date"
    t.integer "hour_from", null: false
    t.integer "hour_to", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
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
    t.string "payment_status"
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "payment_card_last4"
    t.string "region_id"
    t.string "stripe_payment_method_id"
    t.datetime "debited_at", precision: nil
    t.string "payment_wallet"
    t.index ["region_id"], name: "index_room_rentals_on_region_id"
    t.index ["room_offer_id"], name: "index_room_rentals_on_room_offer_id"
    t.index ["stripe_payment_intent_id"], name: "index_room_rentals_on_stripe_payment_intent_id"
    t.index ["user_id"], name: "index_room_rentals_on_user_id"
  end

  create_table "subscription_invoices", force: :cascade do |t|
    t.string "status", default: "0"
    t.string "stripe_id"
    t.string "stripe_payment_intent_id"
    t.string "invoice_number"
    t.string "invoice_pdf"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "subscription_id"
    t.decimal "amount", precision: 10, scale: 2
    t.decimal "crowd_boost_charge_amount", precision: 10, scale: 2
    t.bigint "crowd_boost_id"
    t.bigint "coupon_id"
    t.index ["coupon_id"], name: "index_subscription_invoices_on_coupon_id"
    t.index ["crowd_boost_id"], name: "index_subscription_invoices_on_crowd_boost_id"
    t.index ["subscription_id"], name: "index_subscription_invoices_on_subscription_id"
    t.index ["user_id"], name: "index_subscription_invoices_on_user_id"
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.decimal "amount", precision: 10, scale: 2
    t.string "interval"
    t.string "stripe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "benefit_1"
    t.string "benefit_2"
    t.string "benefit_3"
    t.string "benefit_4"
    t.string "benefit_5"
    t.integer "free_region_zuckerl", default: 0
    t.integer "free_graetzl_zuckerl", default: 0
    t.integer "free_region_zuckerl_monthly_interval", default: 0
    t.integer "free_graetzl_zuckerl_monthly_interval", default: 0
    t.string "image_url"
    t.string "region_id"
    t.decimal "crowd_boost_charge_amount", precision: 10, scale: 2
    t.bigint "crowd_boost_id"
    t.integer "status", default: 0
    t.string "stripe_product_id"
    t.index ["crowd_boost_id"], name: "index_subscription_plans_on_crowd_boost_id"
    t.index ["region_id"], name: "index_subscription_plans_on_region_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "status", default: "0"
    t.string "stripe_id"
    t.string "stripe_plan"
    t.datetime "ends_at", precision: nil
    t.string "region_id"
    t.bigint "user_id"
    t.bigint "subscription_plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "current_period_start", precision: nil
    t.datetime "current_period_end", precision: nil
    t.decimal "crowd_boost_charge_amount", precision: 10, scale: 2
    t.bigint "crowd_boost_id"
    t.string "coupon_code"
    t.bigint "coupon_id"
    t.index ["coupon_id"], name: "index_subscriptions_on_coupon_id"
    t.index ["crowd_boost_id"], name: "index_subscriptions_on_crowd_boost_id"
    t.index ["region_id"], name: "index_subscriptions_on_region_id"
    t.index ["subscription_plan_id"], name: "index_subscriptions_on_subscription_plan_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "user_graetzls", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "graetzl_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["graetzl_id"], name: "index_user_graetzls_on_graetzl_id"
    t.index ["user_id"], name: "index_user_graetzls_on_user_id"
  end

  create_table "user_message_thread_members", force: :cascade do |t|
    t.bigint "user_message_thread_id"
    t.bigint "user_id"
    t.integer "status", default: 0
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "last_message_seen_id", default: 0
    t.index ["user_id"], name: "index_user_message_thread_members_on_user_id"
    t.index ["user_message_thread_id"], name: "index_user_message_thread_members_on_user_message_thread_id"
  end

  create_table "user_message_threads", force: :cascade do |t|
    t.datetime "last_message_at", precision: nil
    t.text "last_message"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "room_rental_id"
    t.integer "thread_type", default: 0
    t.string "user_key"
    t.index ["last_message"], name: "index_user_message_threads_on_last_message"
    t.index ["room_rental_id"], name: "index_user_message_threads_on_room_rental_id"
  end

  create_table "user_messages", force: :cascade do |t|
    t.bigint "user_message_thread_id"
    t.bigint "user_id"
    t.text "message"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_user_messages_on_user_id"
    t.index ["user_message_thread_id"], name: "index_user_messages_on_user_message_thread_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "username", limit: 255
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.boolean "newsletter", default: false, null: false
    t.integer "graetzl_id"
    t.integer "enabled_website_notifications", default: 0
    t.integer "role"
    t.integer "immediate_mail_notifications", default: 0
    t.integer "daily_mail_notifications", default: 0
    t.integer "weekly_mail_notifications", default: 0
    t.string "slug"
    t.text "bio"
    t.string "website"
    t.string "origin"
    t.integer "location_category_id"
    t.boolean "business", default: true
    t.string "stripe_customer_id", limit: 50
    t.string "iban"
    t.integer "address_id"
    t.jsonb "avatar_data"
    t.jsonb "cover_photo_data"
    t.string "region_id"
    t.string "address_street"
    t.string "address_zip"
    t.string "address_city"
    t.geometry "address_coordinates", limit: {:srid=>0, :type=>"geometry"}
    t.string "address_description"
    t.string "stripe_connect_account_id"
    t.boolean "stripe_connect_ready", default: false
    t.string "payment_method"
    t.string "payment_card_last4"
    t.boolean "guest", default: false
    t.integer "free_region_zuckerl", default: 0
    t.integer "free_graetzl_zuckerl", default: 0
    t.boolean "subscribed", default: false
    t.string "payment_wallet"
    t.datetime "deleted_at", precision: nil
    t.integer "trust_level", default: 0, null: false
    t.string "payment_method_stripe_id"
    t.string "payment_exp_month"
    t.string "payment_exp_year"
    t.index ["address_id"], name: "index_users_on_address_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["email", "guest"], name: "index_users_on_email_and_guest", unique: true
    t.index ["graetzl_id"], name: "index_users_on_graetzl_id"
    t.index ["location_category_id"], name: "index_users_on_location_category_id"
    t.index ["region_id"], name: "index_users_on_region_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id"
  end

  create_table "zuckerl_graetzls", force: :cascade do |t|
    t.bigint "zuckerl_id", null: false
    t.bigint "graetzl_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["graetzl_id"], name: "index_zuckerl_graetzls_on_graetzl_id"
    t.index ["zuckerl_id", "graetzl_id"], name: "index_zuckerl_graetzls_on_zuckerl_id_and_graetzl_id", unique: true
    t.index ["zuckerl_id"], name: "index_zuckerl_graetzls_on_zuckerl_id"
  end

  create_table "zuckerls", id: :serial, force: :cascade do |t|
    t.integer "location_id"
    t.string "title"
    t.text "description"
    t.string "aasm_state"
    t.datetime "debited_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "slug"
    t.boolean "entire_region", default: false
    t.string "invoice_number"
    t.string "link"
    t.jsonb "cover_photo_data"
    t.string "region_id"
    t.bigint "user_id"
    t.string "payment_status"
    t.string "payment_method"
    t.string "payment_card_last4"
    t.string "stripe_payment_method_id"
    t.string "stripe_payment_intent_id"
    t.decimal "amount", precision: 10, scale: 2
    t.string "company"
    t.string "name"
    t.string "address"
    t.string "zip"
    t.string "city"
    t.bigint "subscription_id"
    t.string "payment_wallet"
    t.date "starts_at"
    t.date "ends_at"
    t.decimal "crowd_boost_charge_amount", precision: 10, scale: 2
    t.bigint "crowd_boost_id"
    t.index ["crowd_boost_id"], name: "index_zuckerls_on_crowd_boost_id"
    t.index ["location_id"], name: "index_zuckerls_on_location_id"
    t.index ["region_id"], name: "index_zuckerls_on_region_id"
    t.index ["slug"], name: "index_zuckerls_on_slug"
    t.index ["subscription_id"], name: "index_zuckerls_on_subscription_id"
    t.index ["user_id"], name: "index_zuckerls_on_user_id"
  end

  add_foreign_key "activities", "groups", on_delete: :cascade
  add_foreign_key "activity_graetzls", "activities", on_delete: :cascade
  add_foreign_key "activity_graetzls", "graetzls", on_delete: :cascade
  add_foreign_key "billing_addresses", "users", on_delete: :nullify
  add_foreign_key "business_interests_users", "business_interests", on_delete: :cascade
  add_foreign_key "business_interests_users", "users", on_delete: :cascade
  add_foreign_key "contact_list_entries", "users"
  add_foreign_key "coop_demand_graetzls", "coop_demands", on_delete: :cascade
  add_foreign_key "coop_demand_graetzls", "graetzls", on_delete: :cascade
  add_foreign_key "coop_demands", "coop_demand_categories", on_delete: :nullify
  add_foreign_key "coop_demands", "locations", on_delete: :nullify
  add_foreign_key "coop_demands", "users", on_delete: :cascade
  add_foreign_key "coop_suggested_tags", "coop_demand_categories", on_delete: :nullify
  add_foreign_key "coupon_histories", "coupons"
  add_foreign_key "coupon_histories", "users", on_delete: :cascade
  add_foreign_key "crowd_boost_charges", "crowd_boosts", on_delete: :nullify
  add_foreign_key "crowd_boost_charges", "crowd_pledges", on_delete: :nullify
  add_foreign_key "crowd_boost_charges", "room_boosters", on_delete: :nullify
  add_foreign_key "crowd_boost_charges", "subscription_invoices", on_delete: :nullify
  add_foreign_key "crowd_boost_charges", "users", on_delete: :nullify
  add_foreign_key "crowd_boost_charges", "zuckerls", on_delete: :nullify
  add_foreign_key "crowd_boost_pledges", "crowd_boost_slots", on_delete: :nullify
  add_foreign_key "crowd_boost_pledges", "crowd_boosts", on_delete: :nullify
  add_foreign_key "crowd_boost_pledges", "crowd_campaigns", on_delete: :nullify
  add_foreign_key "crowd_boost_slot_graetzls", "crowd_boost_slots", on_delete: :cascade
  add_foreign_key "crowd_boost_slot_graetzls", "graetzls", on_delete: :cascade
  add_foreign_key "crowd_boost_slots", "crowd_boosts", on_delete: :cascade
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
  add_foreign_key "crowd_pledges", "comments", on_delete: :nullify
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
  add_foreign_key "energy_demand_categories", "energy_categories", on_delete: :cascade
  add_foreign_key "energy_demand_categories", "energy_demands", on_delete: :cascade
  add_foreign_key "energy_demand_graetzls", "energy_demands", on_delete: :cascade
  add_foreign_key "energy_demand_graetzls", "graetzls", on_delete: :cascade
  add_foreign_key "energy_demands", "users", on_delete: :cascade
  add_foreign_key "energy_offer_categories", "energy_categories", on_delete: :cascade
  add_foreign_key "energy_offer_categories", "energy_offers", on_delete: :cascade
  add_foreign_key "energy_offer_graetzls", "energy_offers", on_delete: :cascade
  add_foreign_key "energy_offer_graetzls", "graetzls", on_delete: :cascade
  add_foreign_key "energy_offers", "locations", on_delete: :nullify
  add_foreign_key "energy_offers", "users", on_delete: :cascade
  add_foreign_key "favorites", "users", on_delete: :cascade
  add_foreign_key "going_tos", "meeting_additional_dates", on_delete: :nullify
  add_foreign_key "group_graetzls", "graetzls", on_delete: :cascade
  add_foreign_key "group_graetzls", "groups", on_delete: :cascade
  add_foreign_key "group_join_questions", "groups", on_delete: :cascade
  add_foreign_key "group_join_requests", "groups", on_delete: :cascade
  add_foreign_key "group_join_requests", "users", on_delete: :cascade
  add_foreign_key "group_users", "groups", on_delete: :cascade
  add_foreign_key "group_users", "users", on_delete: :cascade
  add_foreign_key "groups", "locations", on_delete: :nullify
  add_foreign_key "groups", "room_demands", on_delete: :nullify
  add_foreign_key "groups", "room_offers", on_delete: :nullify
  add_foreign_key "location_menus", "graetzls", on_delete: :nullify
  add_foreign_key "location_menus", "locations", on_delete: :cascade
  add_foreign_key "meeting_additional_dates", "meetings", on_delete: :cascade
  add_foreign_key "meetings", "groups", on_delete: :nullify
  add_foreign_key "meetings", "polls", on_delete: :nullify
  add_foreign_key "meetings", "users", on_delete: :nullify
  add_foreign_key "poll_graetzls", "graetzls", on_delete: :cascade
  add_foreign_key "poll_graetzls", "polls", on_delete: :cascade
  add_foreign_key "poll_options", "poll_questions", on_delete: :cascade
  add_foreign_key "poll_questions", "polls", on_delete: :cascade
  add_foreign_key "poll_user_answers", "poll_options", on_delete: :cascade
  add_foreign_key "poll_user_answers", "poll_questions", on_delete: :cascade
  add_foreign_key "poll_user_answers", "poll_users", on_delete: :cascade
  add_foreign_key "poll_users", "polls", on_delete: :cascade
  add_foreign_key "poll_users", "users", on_delete: :cascade
  add_foreign_key "polls", "users", on_delete: :cascade
  add_foreign_key "room_boosters", "room_offers", on_delete: :nullify
  add_foreign_key "room_boosters", "users", on_delete: :nullify
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
  add_foreign_key "subscription_invoices", "coupons"
  add_foreign_key "subscription_invoices", "users", on_delete: :nullify
  add_foreign_key "subscriptions", "coupons"
  add_foreign_key "subscriptions", "subscription_plans", on_delete: :nullify
  add_foreign_key "subscriptions", "users", on_delete: :nullify
  add_foreign_key "user_graetzls", "graetzls", on_delete: :cascade
  add_foreign_key "user_graetzls", "users", on_delete: :cascade
  add_foreign_key "user_message_thread_members", "user_message_threads", on_delete: :cascade
  add_foreign_key "user_message_thread_members", "users", on_delete: :cascade
  add_foreign_key "user_message_threads", "room_rentals", on_delete: :nullify
  add_foreign_key "user_messages", "user_message_threads", on_delete: :cascade
  add_foreign_key "user_messages", "users", on_delete: :cascade
  add_foreign_key "users", "location_categories", on_delete: :nullify
  add_foreign_key "zuckerl_graetzls", "graetzls"
  add_foreign_key "zuckerl_graetzls", "zuckerls"
  add_foreign_key "zuckerls", "users", on_delete: :nullify
end
