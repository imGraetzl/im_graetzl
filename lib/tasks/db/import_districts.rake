require 'httparty'

namespace :db do
  desc 'import districts from open gv api'
  task import_districts: :environment do

    def query_api
      query = 'https://data.wien.gv.at/daten/geo?service=WFS&request=GetFeature&version=1.1.0&typeName=ogdwien:BEZIRKSGRENZEOGD&srsName=EPSG:4326&outputFormat=json'
      uri = URI.parse(URI.encode(query))
      HTTParty.get uri
    rescue HTTParty::Error
      nil
    end

    def parse_features(geojson)
      geojson['features'].each do |feature|
        area = RGeo::GeoJSON.decode(feature['geometry'], json_parser: :json)
        area = area.simplify(0.0001)
        name = feature['properties']['NAMEK']
        zip = feature['properties']['DISTRICT_CODE']
        District.find_or_create_by(name: name, zip: zip.to_s, area: area)
      end
    end

    api_response = query_api
    if api_response
      parse_features api_response
    else
      puts 'Cannot import districts from api'
    end
  end

  desc 'import districts from mapbox api'
  task import_districts_mapbox: :environment do

    # ---------------------------------
    # rake db:import_districts_mapbox kaernten ckr1ucx6p1yxj27mr74oxnvpb
    # ---------------------------------

    ARGV.each { |a| task a.to_sym do ; end }
    @region = ARGV[1]
    @map_id = ARGV[2]

    def query_api
      access_token = 'pk.eyJ1IjoibWFsYW5vNzgiLCJhIjoiY2tnMjBmcWpwMG1sNjJ4cXdoZW9iMWM5NyJ9.z-AgKIQ_Op1P4aeRh_lGJw'
      query = "https://api.mapbox.com/datasets/v1/malano78/#{@map_id}/features?access_token=#{access_token}"
      uri = URI.parse(URI.encode(query))
      HTTParty.get uri
    rescue HTTParty::Error
      nil
    end

    def parse_features(geojson)
      features = JSON.parse(geojson.body)['features']
      features.each do |feature|
        if feature['geometry'].present?
          area = RGeo::GeoJSON.decode(feature['geometry'], json_parser: :json)
          name = feature['properties']['name']
          zip = feature['properties']['zip']
          District.find_or_create_by(name: name, zip: zip.to_s, area: area, region_id: @region)
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
