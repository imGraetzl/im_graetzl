namespace :db do
  desc 'import graetzls and districts from mapbox api'
  task import_region_data: :environment do
    # rake db:import_region_data region=kaernten

    map_ids = {
      'wien' => { graetzls: 'ckh0g7hga08kl26o5b1tu57nz' },
      'graz' => { graetzls: 'clisuzool0kjd2bkf7tmhi3l3' },
      'kaernten' => { graetzls: 'ckqhr5awa0djj21p9wbz10jkb' },
      'muehlviertler-kernland' => { graetzls: 'cks61e5tj3p4c20l45zuefvy5' }
    }

    region = Region.get(ENV['region'])

    if region.nil?
      print "Please select region by using:\n\nrake db:import_region_data region=wien\n\n"
      print "Available regions: #{map_ids.keys.join(", ")}\n"
      exit
    end

    graetzl_map_id = map_ids[region.id][:graetzls]
    if graetzl_map_id
      features = HTTP.get("https://api.mapbox.com/datasets/v1/malano78/#{graetzl_map_id}/features", params: {
        access_token: Rails.application.secrets.mapbox_token,
      }).parse(:json)['features']

      features.each do |feature|
        next if feature['geometry'].blank?
        graetzl = Graetzl.find_or_initialize_by(
          name: feature['properties']['title'],
          region_id: region.id,
        )
        graetzl.update(area: RGeo::GeoJSON.decode(feature['geometry'], json_parser: :json))
        print "Imported graetzl #{graetzl.name}\n"
      end
    end

    district_map_id = map_ids[region.id][:districts]
    if district_map_id
      features = HTTP.get("https://api.mapbox.com/datasets/v1/malano78/#{district_map_id}/features", params: {
        access_token: Rails.application.secrets.mapbox_token,
      }).parse(:json)['features']

      features.each do |feature|
        next if feature['geometry'].blank?
        district = District.find_or_initialize_by(
          name: feature['properties']['title'],
          region_id: region.id,
        )
        district.update(area: RGeo::GeoJSON.decode(feature['geometry'], json_parser: :json))
        print "Imported district #{district.name}\n"
      end
    end

  end
end
