class CoordinatesService
  BASE_URI = 'http://data.wien.gv.at/daten/OGDAddressService.svc/GetAddressInfo'
  DISTRICT_NR = 'Bezirk'
  CRS = 'EPSG:4326'

  def initialize(address)
    @street = address.street_name
    @house = address.street_number
    @district = zip_to_numeric(address.zip)
    @best_feature = {}
    #trysome
  end

  def trysome
    features = query_api(uri_params)
    puts features.first['properties'][DISTRICT_NR] 
  end

  def coordinates
    if features = query_api(uri_params)
      puts 'go in'
      find_best_feature(features)
      RGeo::GeoJSON.decode(@best_feature['geometry'], :json_parser => :json)
    end    
  end
  
  private

  #attr_reader :street, :house, :district, :best_feature

  def zip_to_numeric(zip)
    zip.slice(1..2).sub(%r{^0},"") if zip.present?
  end

  def uri_params
    { address: "#{@street} #{@house}", crs: CRS }
  end

  def query_api(params)
    HTTParty.get(BASE_URI, query: params)['features']
  rescue
    puts 'PROBLEM QUERY API'
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