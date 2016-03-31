require 'httparty'

namespace :db do
  desc 'import graetzls from mapbox api'
  task import_graetzls: :environment do

    def query_api
      access_token = 'pk.eyJ1IjoicGVja29taW5nbyIsImEiOiJoVHNQM29zIn0.AVmpyDYApR5mryMCJB1ryw'
      map_id = 'peckomingo.pgi7pcmh'
      # map_id = 'peckomingo.neninlfj'
      query = "http://api.tiles.mapbox.com/v4/#{map_id}/features.json?access_token=#{access_token}"
      uri = URI.parse(URI.encode(query))
      HTTParty.get uri
    rescue HTTParty::Error
      nil
    end

    def parse_features(geojson)
      features = JSON.parse(geojson)['features']
      features.each do |feature|
        if feature['geometry'].present?
          area = RGeo::GeoJSON.decode(feature['geometry'], json_parser: :json)
          name = feature['properties']['title']
          graetzl = Graetzl.find_or_create_by(name: name, area: area)
        end
      end
    end

    api_response = query_api
    if api_response
      parse_features api_response
    else
      puts 'Cannot import graetzls from api'
    end
  end
end
