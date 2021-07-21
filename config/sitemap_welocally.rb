require 'aws-sdk-s3'

# use this sitemap file for all welocally.at regions
# create seperate sitemap file for imgraetzl.at
REGION_LIST = ['kaernten', 'wien']

REGION_LIST.each do |region|

  current_region = Region.get(region)

  # Set the host name for URL creation
  SitemapGenerator::Sitemap.default_host = "https://#{current_region.id}.welocally.at"
  # pick a place safe to write the files
  SitemapGenerator::Sitemap.public_path = 'tmp/'
  # store on S3 using aws-sdk
  SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/#{current_region.id}"
  # Use Localhost (FileAdapter) or AWS Upload
  #SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(ENV['UPLOADS_BUCKET'])
  SitemapGenerator::Sitemap.adapter = SitemapGenerator::FileAdapter.new
  # TASK - change later on heroku:
  #rake sitemap:refresh:no_ping CONFIG_FILE="config/sitemap_welocally.rb"
  SitemapGenerator::Sitemap.create do

    add region_path, changefreq: 'always', priority: 0.9
    add locations_region_path, changefreq: 'always', priority: 1.0
    add meetings_region_path, changefreq: 'always', priority: 1.0
    add rooms_region_path, changefreq: 'always', priority: 1.0
    add tool_offers_region_path, changefreq: 'always', priority: 1.0
    add groups_region_path, changefreq: 'daily', priority: 0.7
    add zuckerls_region_path, changefreq: 'monthly', priority: 0.6

    # Room Categories
    RoomCategory.find_each do |category|
      add rooms_category_region_path(category), changefreq: 'daily', priority: 0.9
    end

    # Location Categories
    LocationCategory.find_each do |category|
      add locations_category_region_path(category), changefreq: 'daily', priority: 0.9
    end

    # Meeting Categories
    EventCategory.find_each do |category|
      add meetings_category_region_path(category), changefreq: 'daily', priority: 0.8
    end

    # Tools Categories
    ToolCategory.find_each do |category|
      add tool_offers_category_region_path(category), changefreq: 'daily', priority: 0.7
    end


    # Districts if used in current_region
    if current_region.use_districts

      District.find_each do |district|
        add district_path(district), changefreq: 'daily', priority: 0.8
        add locations_district_path(district), changefreq: 'daily', priority: 0.8
        add meetings_district_path(district), changefreq: 'daily', priority: 0.8
        add rooms_district_path(district), changefreq: 'daily', priority: 0.8
        add tool_offers_district_path(district), changefreq: 'daily', priority: 0.7

        # Room Categories
        RoomCategory.find_each do |category|
          add rooms_category_district_path(district, category), changefreq: 'daily', priority: 0.8
        end

        # Location Categories
        LocationCategory.find_each do |category|
          add locations_category_district_path(district, category), changefreq: 'daily', priority: 0.8
        end
      end

    end

    # Graetzls
    Graetzl.in(current_region).find_each do |graetzl|
      add graetzl_path(graetzl), changefreq: 'daily', priority: 0.8
      add locations_graetzl_path(graetzl), changefreq: 'daily', priority: 0.7
      add meetings_graetzl_path(graetzl), changefreq: 'daily', priority: 0.5
      add rooms_graetzl_path(graetzl), changefreq: 'daily', priority: 0.5
      add tool_offers_graetzl_path(graetzl), changefreq: 'daily', priority: 0.5

      # Locations
      locations = graetzl.locations.approved
      unless locations.empty?
        locations.find_each do |location|
          add graetzl_location_path(graetzl, location), changefreq: 'daily', priority: 0.9
        end
      end

      # Meetings
      meetings = graetzl.meetings.active
      unless meetings.empty?
        meetings.find_each do |meeting|
          add graetzl_meeting_path(graetzl, meeting), changefreq: 'daily', priority: 0.8
        end
      end
    end

    # Raumteiler
    RoomOffer.in(current_region).find_each do |room_offer|
      add room_offer_path(room_offer), changefreq: 'daily', priority: 0.9
    end

    RoomDemand.in(current_region).find_each do |room_demand|
      add room_demand_path(room_demand), changefreq: 'daily', priority: 0.8
    end

    RoomCall.in(current_region).find_each do |room_call|
      add room_call_path(room_call), changefreq: 'daily', priority: 0.6
    end

    # Groups
    Group.in(current_region).find_each do |group|
      add group_path(group), changefreq: 'weekly', priority: 0.5
    end

    # Toolteiler
    ToolOffer.in(current_region).non_deleted.find_each do |tool_offer|
      add tool_offer_path(tool_offer), changefreq: 'daily', priority: 0.7
    end

    # Info Help Pages
    add info_path, changefreq: 'monthly', priority: 0.4
    add info_anbieter_und_locations_path, changefreq: 'monthly', priority: 0.4
    add info_events_und_workshops_path, changefreq: 'monthly', priority: 0.4
    add info_raumteiler_path, changefreq: 'monthly', priority: 0.4
    add info_toolteiler_path, changefreq: 'monthly', priority: 0.4
    add info_gruppen_path, changefreq: 'monthly', priority: 0.4
    add unterstuetzer_team_path, changefreq: 'monthly', priority: 0.4

    # Info Pages
    add info_agb_path, changefreq: 'never', priority: 0.3
    add info_datenschutz_path, changefreq: 'never', priority: 0.3
    add info_impressum_path, changefreq: 'never', priority: 0.3
    add info_infos_zum_graetzlzuckerl_path, changefreq: 'never', priority: 0.3

    # Registration (only get paths)
    add new_user_session_path, changefreq: 'never', priority: 0.3
    add new_password_path, changefreq: 'never', priority: 0.3
    add edit_password_path, changefreq: 'never', priority: 0.3
    add new_confirmation_path, changefreq: 'never', priority: 0.3
    add new_registration_path, changefreq: 'never', priority: 0.3
  end

end
