# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = 'http://www.imgraetzl.at'

SitemapGenerator::Sitemap.create do
  # Districts
  add districts_path, changefreq: 'always', priority: 0.7
  District.find_each do |district|
    add district_path(district), changefreq: 'always', priority: 0.7
    add district_locations_path(district) unless district.locations.empty?
    add district_meetings_path(district) unless district.meetings.empty?
  end

  # Graetzls
  Graetzl.find_each do |graetzl|
    add graetzl_path(graetzl), changefreq: 'always', priority: 0.7

    # Locations
    locations = graetzl.locations.approved
    unless locations.empty?
      add graetzl_locations_path(graetzl)
      locations.find_each do |location|
        add graetzl_location_path(graetzl, location), priority: 0.7
      end
    end

    # Meetings
    meetings = graetzl.meetings.basic
    unless meetings.empty?
      add graetzl_meetings_path(graetzl)
      meetings.find_each do |meeting|
        add graetzl_meeting_path(graetzl, meeting), priority: 0.7
      end
    end
  end

  # Info Pages
  add info_agb_path, changefreq: 'never', priority: 0.3
  add info_datenschutz_path, changefreq: 'never', priority: 0.3
  add info_impressum_path, changefreq: 'never', priority: 0.3
  add info_infos_zum_graetzlzuckerl_path, changefreq: 'never', priority: 0.3
  add info_fragen_und_antworten_path, changefreq: 'never', priority: 0.3
  add info_zur_graetzlmarie_path, changefreq: 'never', priority: 0.3

  # Registration (only get paths)
  add new_user_session_path, changefreq: 'never', priority: 0.3
  add new_password_path, changefreq: 'never', priority: 0.3
  add edit_password_path, changefreq: 'never', priority: 0.3
  add new_confirmation_path, changefreq: 'never', priority: 0.3
  add new_registration_path, changefreq: 'never', priority: 0.3
end
