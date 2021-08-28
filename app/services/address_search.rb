class AddressSearch

  def search(region, query)
    return [] if query.blank?
    query.strip!
    # search_wien_gv(region, query)
    # search_mapbox(region, query)
    search_opendata(region, query)
  end

  # private

  WIEN_GV_URL = 'https://data.wien.gv.at/daten/OGDAddressService.svc/GetAddressInfo'

  def search_wien_gv(region, query)
    response = HTTP.get(WIEN_GV_URL, params: { crs: "EPSG:4326", Address: query}).parse(:json)
    response['features'].first(10).map do |address|
      coordinates = address.dig('geometry', 'coordinates')
      {
        value: address.dig('properties', 'Adresse'),
        data: {
          coordinates: coordinates,
          city: address.dig('properties', 'Municipality'),
          zip: address.dig('properties', 'PostalCode'),
          graetzl_id: Graetzl.find_by_coords(region, coordinates)&.id,
        }
      }
    end
  end

  MAPBOX_URL = 'https://api.mapbox.com/geocoding/v5/mapbox.places/'

  def search_mapbox(region, query)
    response = HTTP.get(MAPBOX_URL + ERB::Util.url_encode(query) + ".json", params: {
      access_token: Rails.application.secrets.mapbox_token,
      types: "address",
      country: "at",
      language: "de",
      autocomplete: true,
      limit: 10,
      bbox: "14.452515,46.607469,14.987411,46.845634", # TODO: use from region
    }).parse(:json)

    response['features'].map do |address|
      coordinates = address['center']
      {
        value: address['text_de'],
        data: {
          coordinates: coordinates,
          city: address['context'][1]['text_de'],
          zip: address['context'][0]['text_de'],
          graetzl_id: Graetzl.find_by_coords(region, coordinates)&.id,
        }
      }
    end.select{|f| f[:data][:graetzl_id].present? }
  end

  OPEN_DATA_URL = "http://api.opendata.host/1.0/address/find"

  def search_opendata(region, query)
    if query.match?(/\d+\Z/)
      street, _, number = query.rpartition(/\s+/)
    else
      street, number = query, nil
    end

    response = HTTP.basic_auth(
      user: Rails.application.secrets.open_data_key, pass: nil
    ).get(OPEN_DATA_URL, params: {
      country: "at",
      # city: TODO,
      "street-address": street,
      "street-number": number,
      limit: 10,
    }).parse(:json)

    return [] if response["addresses"].blank?

    response["addresses"].map do |address|
      coordinates = [address['longitude'], address['latitude']]
      {
        value: "#{address['street']} #{address['houseNumber']}",
        data: {
          coordinates: coordinates,
          city: address['city'],
          zip: address['postalCode'],
          graetzl_id: Graetzl.find_by_coords(region, coordinates)&.id,
        }
      }
    end
  end

end