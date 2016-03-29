require 'httparty'

namespace :db do
  desc 'import graetzls from mapbox api'
  task import_graetzls: :environment do

    def query_api
      access_token = 'pk.eyJ1IjoicGVja29taW5nbyIsImEiOiJoVHNQM29zIn0.AVmpyDYApR5mryMCJB1ryw'
      map_id = 'peckomingo.pgi7pcmh'
      query = "http://api.tiles.mapbox.com/v4/#{map_id}/features.json?access_token=#{access_token}"
      uri = URI.parse(URI.encode(query))
      begin
        HTTParty.get(uri)
      rescue
        nil
      end
    end

    def parse_features(geojson)
      features = JSON.parse(geojson)['features']
      features.each do |feature|
        if feature['geometry'].present?
          polygon = RGeo::GeoJSON.decode(feature['geometry'], :json_parser => :json)
          name = feature['properties']['title']
          graetzl = Graetzl.find_or_create_by(name: name, area: polygon)
        end
      end
    end

    api_response = query_api
    if api_response
      parse_features(api_response)
    else
      puts 'Cannot import districts from api'
    end
  end
end
