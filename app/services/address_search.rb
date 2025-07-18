class AddressSearch

  def search(region, query, graetzl_id = nil)
    return [] if query.blank?
    query.strip!
    # search_wien_gv(region, query)
    search_mapbox(region, query, graetzl_id)
    # search_opendata(region, query)
  end

  private

  WIEN_GV_URL = 'https://data.wien.gv.at/daten/OGDAddressService.svc/GetAddressInfo'

  def search_wien_gv(region, query)
    response = HTTP.get(WIEN_GV_URL, params: { crs: "EPSG:4326", Address: query }).parse(:json)
    response['features'].map do |address|
      coordinates = address.dig('geometry', 'coordinates')
      graetzl = Graetzl.find_by_coords(region, coordinates)
      {
        value: address.dig('properties', 'Adresse'),
        data: {
          coordinates: coordinates,
          city: address.dig('properties', 'Municipality'),
          zip: address.dig('properties', 'PostalCode'),
          graetzl_id: graetzl&.id,
          graetzl_name: graetzl&.name,
        }
      }
    end
  end

  MAPBOX_URL = 'https://api.mapbox.com/geocoding/v5/mapbox.places/'

  def search_mapbox(region, query, graetzl_id)
    # if needed add graetzl.proximity to db and in search
    response = HTTP.get(MAPBOX_URL + ERB::Util.url_encode(query) + ".json", params: {
      access_token: ENV['MAPBOX_TOKEN'],
      country: "at",
      language: "de",
      types: 'address',
      autocomplete: true,
      limit: 10,
      bbox: region.bounds.flatten.join(","),
      proximity: region&.proximity ? region&.proximity : '',
    }).parse(:json)

    return [] unless response['features'].is_a?(Array)

    response['features'].filter_map do |address|
      coordinates = address['center']
      graetzl = Graetzl.find_by_coords(region, coordinates)
      city = region.id == 'wien' ? address['context'][2]['text_de'] : address['context'][1]['text_de']
      next if graetzl.nil?
      # Skip addresses without number if user has entered a number
      next if query.match?(/\d+\Z/) && address['address'].blank?
      {
        value: address['place_name_de'].split(",").first,
        data: {
          coordinates: coordinates,
          city: city,
          zip: address['context'][0]['text_de'],
          graetzl_id: graetzl&.id,
          graetzl_name: graetzl&.name,
        }
      }
    end
  end

  OPEN_DATA_URL = "http://api.opendata.host/1.0/address/find"

  def search_opendata(region, query)
    if query.match?(/\d+\Z/)
      street, _, number = query.rpartition(/\s+/)
    else
      street, number = query, nil
    end

    response = HTTP.basic_auth(
      user: ENV['OPEN_DATA_KEY'], pass: nil
    ).get(OPEN_DATA_URL, params: {
      country: "at",
      # city: TODO?,
      "street-address": street,
      "street-number": number,
      limit: 20,
    }).parse(:json)

    return [] if response["addresses"].blank?

    response["addresses"].filter_map do |address|
      coordinates = [address['longitude'], address['latitude']]
      graetzl = Graetzl.find_by_coords(region, coordinates)
      next if graetzl.nil?
      {
        value: "#{address['street']} #{address['houseNumber']}",
        data: {
          coordinates: coordinates,
          city: address['city'],
          zip: address['postalCode'],
          graetzl_id: graetzl&.id,
          graetzl_name: graetzl&.name,
        }
      }
    end
  end

end
