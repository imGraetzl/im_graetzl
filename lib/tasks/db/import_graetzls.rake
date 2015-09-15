# namespace :db do
#   desc "import graetzl from geojson"
#   task import_graetzl: :environment do
#     Graetzl.destroy_all
#     geojson = File.read(Rails.root+"public/graetzl.json")
#     feature_collection = JSON.parse(geojson)['features']

#     feature_collection.each do |feature|
#       polygon = RGeo::GeoJSON.decode(feature['geometry'], :json_parser => :json)
#       name = feature['properties']['name']
#       Graetzl.create(name: name, area: polygon).save!
#     end
#   end
# end

require 'httparty'

namespace :db do
  desc 'import graetzls from mapbox api'
  task import_graetzls: :environment do

    def query_api    
      access_token = 'pk.eyJ1IjoicGVja29taW5nbyIsImEiOiJoVHNQM29zIn0.AVmpyDYApR5mryMCJB1ryw'
      map_id = 'peckomingo.m4egogoc'
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
      # File.open("public/graetzls_tmp.json","w") do |f|
      #   f.write(JSON.pretty_generate(features))
      # end
      features.each do |feature|
        if feature['geometry'].present?
          polygon = RGeo::GeoJSON.decode(feature['geometry'], :json_parser => :json)
          name = feature['properties']['title']
          #name = name.partition(',').first if name
          #graetzl = Graetzl.find_or_create_by(name: name, area: polygon) if polygon.geometry_type.type_name == 'Polygon'
          graetzl = Graetzl.find_or_create_by(name: name, area: polygon)
        end
      end
    end

    #api_response = File.read(Rails.root+"public/graetzl.json")
    api_response = query_api
    if api_response
      parse_features(api_response)
    else
      puts 'Cannot import districts from api'
    end
  end
end