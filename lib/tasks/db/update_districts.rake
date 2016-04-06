require 'httparty'

namespace :db do
  desc 'update districts from open gv api'
  task update_districts: :environment do

    def query_api
      query = 'http://data.wien.gv.at/daten/geo?service=WFS&request=GetFeature&version=1.1.0&typeName=ogdwien:BEZIRKSGRENZEOGD&srsName=EPSG:4326&outputFormat=json'
      uri = URI.parse(URI.encode(query))
      HTTParty.get uri
    rescue HTTParty::Error
      nil
    end

    def parse_features(geojson)
      geojson['features'].each do |feature|
        area = RGeo::GeoJSON.decode(feature['geometry'], json_parser: :json)
        area = area.simplify(0.0001)
        zip = feature['properties']['DISTRICT_CODE']
        district = District.find_by_zip zip
        district.update(area: area) if district
      end
    end

    api_response = query_api
    if api_response
      parse_features api_response
    else
      puts 'Cannot import districts from api'
    end
  end
end
