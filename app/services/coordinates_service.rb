class CoordinatesService
  BASE_URI = 'http://data.wien.gv.at/daten/OGDAddressService.svc/GetAddressInfo'
  DISTRICT_NR = 'Bezirk'
  CRS = 'EPSG:4326'

  def initialize(address)
    @street = address.street_name
    @house = address.street_number
    @district = zip_to_numeric(address.zip)
  end

  def coordinates
    if features = query_api(uri_params)
      RGeo::GeoJSON.decode(find_best_feature(features)['geometry'], json_parser: :json)
    else
      nil
    end
  end
  
  private

  attr_reader :street, :house, :district

  def zip_to_numeric(zip)
    zip.slice(1..2).sub(%r{^0},"") if zip.present?
  end

  def uri_params
    { address: "#{@street} #{@house}", crs: CRS }
  end

  def query_api(params)
    HTTParty.get(BASE_URI, query: params)['features']
  rescue
    nil
  end

  def find_best_feature(features, best=nil)
    current = features.first
    best ||= current
    if (current && @district) && (current['properties'][DISTRICT_NR] != @district)
      return find_best_feature(features.drop(1), best)
    end
    return current || best
  end
end