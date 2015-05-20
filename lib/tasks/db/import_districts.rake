require 'httparty'

namespace :db do
  desc "import districts from open gv"
  task import_districts: :environment do
    District.destroy_all
    api_response = query_api
    if api_response
      parse_features(api_response)
    else
      puts 'Cannot import districts from api'
    end
  end

  def query_api
    query = 'http://data.wien.gv.at/daten/geo?service=WFS&request=GetFeature&version=1.1.0&typeName=ogdwien:BEZIRKSGRENZEOGD&srsName=EPSG:4326&outputFormat=json'
    uri = URI.parse(URI.encode(query))
    begin
      HTTParty.get(uri)
    rescue
      nil
    end
  end

  def parse_features(geojson)
    geojson['features'].each do |feature|
      polygon = RGeo::GeoJSON.decode(feature['geometry'], :json_parser => :json)
      name = feature['properties']['NAMEK']
      zip = feature['properties']['DISTRICT_CODE']
      District.create(name: name, zip: zip, area: polygon).save!
    end
  end
end