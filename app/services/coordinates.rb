class Coordinates < BaseService

  def initialize(address)
    @street, @street_nr = address.street_name, address.street_number
    @district_nr = address.district_nr
    def district_nr
      zip.slice(1..2).sub(%r{^0},"") unless zip.blank?
    end

  end

  def call
    response = api_connection.request request
    parse(response) if response.kind_of? Net::HTTPSuccess
  rescue *HTTP_ERRORS
    nil
  end

  private

  attr_reader :street, :street_nr, :district_nr

  def url
    @url ||= URI(BASE_URL)
  end

  def api_connection
    Net::HTTP.new url.host, url.port
  end

  def request
    params = { address: "#{@street} #{@street_nr}", crs: 'EPSG:4326' }
    url.query = URI.encode_www_form params
    Net::HTTP::Get.new url
  end

  def parse(response)
    json = JSON.parse response.body
    if json['features']
      geometry = best_match(json['features'])['geometry']
      RGeo::GeoJSON.decode geometry, json_parser: :json
    else
      nil
    end
  rescue JSON::ParserError
    nil
  end

  def best_match(features)
    return features.first unless @district_nr
    match features
  end

  def match(features, best=nil)
    feature = features.first
    best ||= feature
    unless feature['properties']['Bezirk'] == @district_nr
      return match(features.drop(1), best) unless features.size < 2
    end
    feature || best
  end
end
