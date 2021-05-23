class AddressResolver
  SEARCH_URL = 'http://data.wien.gv.at/daten/OGDAddressService.svc/GetAddressInfo'

  def self.from_json(json)
    feature = JSON.parse(json) rescue {}
    new(feature)
  end

  def self.from_street(street)
    params = { address: street, crs: 'EPSG:4326' }
    results = HTTParty.get("#{SEARCH_URL}?#{params.to_query}")
    new(results['features']&.first)
  end

  def initialize(feature)
    @feature = feature
  end

  def valid?
    @feature.present?
  end

  def graetzl
    Graetzl.where('ST_CONTAINS(area, :point)', point: coordinates).first
  end

  def address_fields
    {
      coordinates: coordinates,
      street_name: @feature['properties']['StreetName'],
      street_number: @feature['properties']['StreetNumber'],
      zip: @feature['properties']['PostalCode'],
      city: @feature['properties']['Municipality']
    }
  end

  private

  def coordinates
    # Maybe we can just use @feature['geometry']['coordinates'] ?
    RGeo::GeoJSON.decode(@feature['geometry'], json_parser: :json)
  end

end