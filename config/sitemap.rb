# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = 'http://www.imgraetzl.at'

SitemapGenerator::Sitemap.create do
  # Districts
  add districts_path
  District.find_each do |district|
    add district_path(district), lastmod: district.updated_at, changefreq: 'always'
    add district_locations_path(district) unless district.locations.empty?
    add district_meetings_path(district) unless district.meetings.empty?
  end

  # Zuckerl
  add zuckerl_districts_path, changefreq: 'monthly'

  # Graetzls
  Graetzl.find_each do |graetzl|
    add graetzl_path(graetzl), lastmod: graetzl.updated_at, changefreq: 'always'

    # Locations
    locations = graetzl.locations.approved
    unless locations.empty?
      add graetzl_locations_path(graetzl)
      locations.find_each do |location|
        add graetzl_location_path(graetzl, location)
      end
    end

    # Meetings
    meetings = graetzl.meetings.basic
    unless meetings.empty?
      add graetzl_meetings_path(graetzl)
      meetings.find_each do |meeting|
        add graetzl_meetings_path(graetzl, meeting)
      end
    end
  end

  # Info Pages
  add info_agb_path, changefreq: 'never'
  add info_datenschutz_path, changefreq: 'never'
  add info_impressum_path, changefreq: 'never'
  add info_infos_zum_graetzlzuckerl_path, changefreq: 'never'
  add info_fragen_und_antworten_path, changefreq: 'never'
end
