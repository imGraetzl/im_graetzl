require 'aws-sdk-s3'

Region.all.each do |region|

  # Set the host name for URL creation
  if Rails.env.production? && region.id == 'wien'
    SitemapGenerator::Sitemap.default_host = "https://www.#{region.host}"
  else
    SitemapGenerator::Sitemap.default_host = "https://#{region.host}"
  end
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

  # Use for Localhost - Comment Line out after Testing
  # SitemapGenerator::Sitemap.adapter = SitemapGenerator::FileAdapter.new
  # Use for Localhost - Comment Line out after Testing

  # TASK - setup on heroku:
  #rake sitemap:refresh:no_ping

  SitemapGenerator::Sitemap.create do

    add region_index_path, changefreq: 'always', priority: 1.0
    add region_locations_path, changefreq: 'always', priority: 1.0
    add region_meetings_path, changefreq: 'always', priority: 1.0
    add region_rooms_path, changefreq: 'always', priority: 1.0
    add region_energies_path, changefreq: 'always', priority: 1.0
    add region_coop_demands_path, changefreq: 'always', priority: 1.0
    add region_crowd_campaigns_path, changefreq: 'always', priority: 1.0
    add start_crowd_campaigns_path, changefreq: 'always', priority: 1.0
    add region_groups_path, changefreq: 'daily', priority: 0.5
    add region_zuckerls_path, changefreq: 'weekly', priority: 0.5

    # Room Categories
    add region_rooms_path(category: 'kurzzeitmiete'), changefreq: 'daily', priority: 0.9
    RoomCategory.find_each do |category|
      add region_rooms_path(category: category), changefreq: 'daily', priority: 0.9
    end

    # Location Categories
    add region_locations_path(category: 'goodies'), changefreq: 'daily', priority: 0.9
    add region_locations_path(category: 'menus'), changefreq: 'daily', priority: 0.9
    add region_locations_path(category: 'online-shops'), changefreq: 'daily', priority: 0.9
    LocationCategory.find_each do |category|
      add region_locations_path(category: category), changefreq: 'daily', priority: 0.9
    end

    # Meeting Categories
    EventCategory.visible.find_each do |category|
      add region_meetings_path(category: category), changefreq: 'daily', priority: 0.7
    end

    # CoopDemand Categories
    CoopDemandCategory.find_each do |category|
      add region_coop_demands_path(category: category), changefreq: 'daily', priority: 0.9
    end

    # Districts if used in region
    if region.use_districts?
      District.find_each do |district|
        add district_index_path(district), changefreq: 'daily', priority: 0.8
        add district_locations_path(district), changefreq: 'daily', priority: 0.8
        add district_meetings_path(district), changefreq: 'daily', priority: 0.8
        add district_rooms_path(district), changefreq: 'daily', priority: 0.8
        add district_zuckerls_path(district), changefreq: 'weekly', priority: 0.7

        # Location Categories
        LocationCategory.find_each do |category|
          add district_locations_path(district, category: category), changefreq: 'daily', priority: 0.7
        end

        # Room Categories
        RoomCategory.find_each do |category|
          add district_rooms_path(district, category: category), changefreq: 'daily', priority: 0.7
        end

      end
    end

    # Graetzls
    Graetzl.in(region).find_each do |graetzl|
      add graetzl_path(graetzl), changefreq: 'daily', priority: 0.9
      add locations_graetzl_path(graetzl), changefreq: 'daily', priority: 0.8
      add meetings_graetzl_path(graetzl), changefreq: 'daily', priority: 0.8
      add rooms_graetzl_path(graetzl), changefreq: 'daily', priority: 0.5
      add zuckerls_graetzl_path(graetzl), changefreq: 'weekly', priority: 0.5

      # Locations
      locations = graetzl.locations.approved
      unless locations.empty?
        locations.find_each do |location|
          add graetzl_location_path(graetzl, location), changefreq: 'daily', priority: 1.0
        end
      end

      # Meetings
      meetings = graetzl.meetings.upcoming
      unless meetings.empty?
        meetings.find_each do |meeting|
          add graetzl_meeting_path(graetzl, meeting), changefreq: 'daily', priority: 0.9
        end
      end
    end

    # CrowdCampaigns
    CrowdCampaign.in(region).scope_public.find_each do |crowd_campaign|
      add crowd_campaign_path(crowd_campaign), changefreq: 'daily', priority: 1.0
    end

    # Crowd Boosts
    CrowdBoost.in(region).enabled.find_each do |crowd_boost|
      add crowd_boost_path(crowd_boost), changefreq: 'weekly', priority: 1.0
    end

    # Polls
    Poll.in(region).enabled.find_each do |poll|
      add poll_path(poll), changefreq: 'daily', priority: 0.8
    end

    # Raumteiler
    RoomOffer.in(region).enabled.find_each do |room_offer|
      add room_offer_path(room_offer), changefreq: 'daily', priority: 0.9
    end

    RoomDemand.in(region).enabled.find_each do |room_demand|
      add room_demand_path(room_demand), changefreq: 'daily', priority: 0.8
    end

    # Energieteiler
    EnergyOffer.in(region).enabled.find_each do |energy_offer|
      add energy_offer_path(energy_offer), changefreq: 'daily', priority: 0.6
    end

    EnergyDemand.in(region).enabled.find_each do |energy_demand|
      add energy_demand_path(energy_demand), changefreq: 'daily', priority: 0.6
    end

    # Coop & Share
    CoopDemand.in(region).enabled.find_each do |coop_demand|
      add coop_demand_path(coop_demand), changefreq: 'daily', priority: 0.8
    end

    # Groups
    Group.in(region).find_each do |group|
      add group_path(group), changefreq: 'weekly', priority: 0.5
    end

    # Static Vienna Pages
    if region.id == 'wien'
      add good_morning_dates_path, changefreq: 'daily', priority: 0.9
      add leerstand_path, changefreq: 'daily', priority: 1.0
    end

    if region.id == 'graz'
      add leerstand_path, changefreq: 'daily', priority: 1.0
    end
    
    if region.id == 'linz'
    end

    if region.id == 'innsbruck'
      add leerstand_path, changefreq: 'daily', priority: 1.0
    end

    if region.use_subscription?
      add subscription_plans_path, changefreq: 'daily', priority: 0.9
    end

    # Info Help Pages
    add info_path, changefreq: 'monthly', priority: 0.4
    add info_anbieter_und_locations_path, changefreq: 'monthly', priority: 0.4
    add info_events_und_workshops_path, changefreq: 'monthly', priority: 0.4
    add info_raumteiler_path, changefreq: 'monthly', priority: 0.4
    add info_energieteiler_path, changefreq: 'monthly', priority: 0.4
    add info_coop_share_path, changefreq: 'monthly', priority: 0.4
    add info_crowdfunding_path, changefreq: 'monthly', priority: 0.4
    add info_zuckerl_path, changefreq: 'never', priority: 0.4

    # Info Pages
    add info_agb_path, changefreq: 'never', priority: 0.3
    add info_datenschutz_path, changefreq: 'never', priority: 0.3
    add info_impressum_path, changefreq: 'never', priority: 0.3

  end

  SitemapGenerator::Sitemap.ping_search_engines if Rails.env.production?

end
