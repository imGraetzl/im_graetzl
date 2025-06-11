namespace :db do
  desc 'import graetzls and districts from mapbox api'
  task import_region_data: :environment do
    # rake db:import_region_data region=kaernten

    map_ids = {
      'wien' => { graetzls: 'ckh0g7hga08kl26o5b1tu57nz' },
      'graz' => { graetzls: 'clisuzool0kjd2bkf7tmhi3l3' },
      'linz' => { graetzls: 'clui6os6j715s1vs1zjx1avt5' },
      'innsbruck' => { graetzls: 'cm5f6tv4o0txd1oo3cqgdlfon' },
      'kaernten' => { graetzls: 'ckqhr5awa0djj21p9wbz10jkb' },
      'muehlviertler-kernland' => { graetzls: 'cks61e5tj3p4c20l45zuefvy5' }
    }

    region = Region.get(ENV['region'])

    if region.nil?
      puts "\nBitte Region angeben, z. B.: rake db:import_region_data region=wien"
      puts "Verfügbare Regionen: #{map_ids.keys.join(', ')}"
      exit
    end

    def safe_decode_geometry(geometry_hash, context_name)
      return nil unless geometry_hash.is_a?(Hash) && geometry_hash['type'].present?

      RGeo::GeoJSON.decode(geometry_hash, json_parser: :json)
    rescue MultiJson::ParseError => e
      puts "⚠️ Fehler beim Parsen von GeoJSON für #{context_name}: #{e.message}"
      nil
    end

    graetzl_map_id = map_ids[region.id][:graetzls]
    if graetzl_map_id
      features = HTTP.get("https://api.mapbox.com/datasets/v1/malano78/#{graetzl_map_id}/features", params: {
        access_token: Rails.application.secrets.mapbox_token,
      }).parse(:json)['features']

      features.each do |feature|
        geometry = safe_decode_geometry(feature['geometry'], feature.dig('properties', 'title'))
        next if geometry.blank?

        graetzl = Graetzl.find_or_initialize_by(
          name: feature['properties']['title'],
          region_id: region.id,
        )
        graetzl.update(area: geometry)
        puts "✅ Importiert: Graetzl #{graetzl.name}"
      end
    end

    district_map_id = map_ids[region.id][:districts]
    if district_map_id
      features = HTTP.get("https://api.mapbox.com/datasets/v1/malano78/#{district_map_id}/features", params: {
        access_token: Rails.application.secrets.mapbox_token,
      }).parse(:json)['features']

      features.each do |feature|
        geometry = safe_decode_geometry(feature['geometry'], feature.dig('properties', 'title'))
        next if geometry.blank?

        district = District.find_or_initialize_by(
          name: feature['properties']['title'],
          region_id: region.id,
        )
        district.update(area: geometry)
        puts "✅ Importiert: District #{district.name}"
      end
    end
  end
end
