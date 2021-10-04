require 'aws-sdk-s3'

Region.all.each do |region|

  # Set the host name for URL creation
  SitemapGenerator::Sitemap.default_host = "https://#{region.host}"
  # pick a place safe to write the files
  SitemapGenerator::Sitemap.public_path = 'tmp/'
  # store on S3 using aws-sdk
  SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/#{region.id}"
  # Use Localhost (FileAdapter) or AWS Upload

  SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(ENV['UPLOADS_BUCKET'],
    aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    aws_region: ENV['AWS_REGION']
  )

  #SitemapGenerator::Sitemap.adapter = SitemapGenerator::FileAdapter.new
  # TASK - setup on heroku:
  #rake sitemap:refresh:no_ping
  #rake sitemap:refresh:no_ping CONFIG_FILE="config/sitemap.rb"
  SitemapGenerator::Sitemap.create do

    add region_index_path, changefreq: 'always', priority: 0.9
    add region_locations_path, changefreq: 'always', priority: 1.0
    add region_meetings_path, changefreq: 'always', priority: 1.0
    add region_rooms_path, changefreq: 'always', priority: 1.0
    add region_tool_offers_path, changefreq: 'always', priority: 1.0
    add region_coop_demands_path, changefreq: 'always', priority: 1.0
    add region_groups_path, changefreq: 'daily', priority: 0.6
    add region_zuckerls_path, changefreq: 'monthly', priority: 0.6

    # Room Categories
    RoomCategory.find_each do |category|
      add region_rooms_path(category: category), changefreq: 'daily', priority: 0.9
    end

    # CoopDemand Categories
    CoopDemandCategory.find_each do |category|
      add region_coop_demands_path(category: category), changefreq: 'daily', priority: 0.9
    end

    # Location Categories
    LocationCategory.find_each do |category|
      add region_locations_path(category: category), changefreq: 'daily', priority: 0.9
    end

    # Meeting Categories
    EventCategory.find_each do |category|
      add region_meetings_path(category: category), changefreq: 'daily', priority: 0.8
    end

    # Tools Categories
    ToolCategory.find_each do |category|
      add region_tool_offers_path(category: category), changefreq: 'daily', priority: 0.7
    end

    # Districts if used in region
    if region.use_districts?
      District.find_each do |district|
        add district_index_path(district), changefreq: 'daily', priority: 0.8
        add district_locations_path(district), changefreq: 'daily', priority: 0.8
        add district_meetings_path(district), changefreq: 'daily', priority: 0.8
        add district_rooms_path(district), changefreq: 'daily', priority: 0.8
        add district_coop_demands_path(district), changefreq: 'daily', priority: 0.8
        add district_tool_offers_path(district), changefreq: 'daily', priority: 0.7
      end
    end

    # Graetzls
    Graetzl.in(region).find_each do |graetzl|
      add graetzl_path(graetzl), changefreq: 'daily', priority: 0.8
      add locations_graetzl_path(graetzl), changefreq: 'daily', priority: 0.7
      add meetings_graetzl_path(graetzl), changefreq: 'daily', priority: 0.5
      add rooms_graetzl_path(graetzl), changefreq: 'daily', priority: 0.5
      add tool_offers_graetzl_path(graetzl), changefreq: 'daily', priority: 0.5
      add coop_demands_graetzl_path(graetzl), changefreq: 'daily', priority: 0.5

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
    RoomOffer.in(region).find_each do |room_offer|
      add room_offer_path(room_offer), changefreq: 'daily', priority: 0.9
    end

    RoomDemand.in(region).find_each do |room_demand|
      add room_demand_path(room_demand), changefreq: 'daily', priority: 0.8
    end

    CoopDemand.in(region).find_each do |coop_demand|
      add coop_demand_path(coop_demand), changefreq: 'daily', priority: 0.8
    end

    # Groups
    Group.in(region).find_each do |group|
      add group_path(group), changefreq: 'weekly', priority: 0.5
    end

    # Toolteiler
    ToolOffer.in(region).non_deleted.find_each do |tool_offer|
      add tool_offer_path(tool_offer), changefreq: 'daily', priority: 0.7
    end

    # Info Help Pages
    add info_path, changefreq: 'monthly', priority: 0.4
    add info_anbieter_und_locations_path, changefreq: 'monthly', priority: 0.4
    add info_events_und_workshops_path, changefreq: 'monthly', priority: 0.4
    add info_raumteiler_path, changefreq: 'monthly', priority: 0.4
    add info_toolteiler_path, changefreq: 'monthly', priority: 0.4
    add info_coop_share_path, changefreq: 'monthly', priority: 0.4
    add info_zuckerl_path, changefreq: 'never', priority: 0.4

    # Info Pages
    add info_agb_path, changefreq: 'never', priority: 0.3
    add info_datenschutz_path, changefreq: 'never', priority: 0.3
    add info_impressum_path, changefreq: 'never', priority: 0.3

    # Registration (only get paths)
    add new_user_session_path, changefreq: 'never', priority: 0.3
    add new_password_path, changefreq: 'never', priority: 0.3
    add edit_password_path, changefreq: 'never', priority: 0.3
    add new_confirmation_path, changefreq: 'never', priority: 0.3
    add new_registration_path, changefreq: 'never', priority: 0.3
  end

end
