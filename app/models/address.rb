class Address < ActiveRecord::Base
  # associations
  belongs_to :addressable, polymorphic: true

  # class methods
  def self.new_from_feature(feature)
    begin
      feature = JSON.parse(feature)
      Address.new(
        coordinates: RGeo::GeoJSON.decode(feature['geometry'], :json_parser => :json),
        street_name: feature['properties']['StreetName'],
        street_number: feature['properties']['StreetNumber'],
        zip: feature['properties']['PostalCode'],
        city: feature['properties']['Municipality'])
    rescue JSON::ParserError => e
      Address.new
    end    
  end

  def self.attributes_from_feature(feature)
    begin
      feature = JSON.parse(feature)
      a = { coordinates: RGeo::GeoJSON.decode(feature['geometry'], :json_parser => :json),
        street_name: feature['properties']['StreetName'],
        street_number: feature['properties']['StreetNumber'],
        zip: feature['properties']['PostalCode'],
        city: feature['properties']['Municipality']
      }
    rescue JSON::ParserError => e
      #something?
    end
  end

  # instance methods
  def graetzls
    Graetzl.where('ST_CONTAINS(area, :point)', point: coordinates)
  end

  def graetzl
    graetzls.first
  end

  def merge_feature(attrs)
    self.attributes = attrs.slice('street_name',
      'coordinates',
      'street_number',
      'city',
      'zip')
  end

  private

    def self.query_address_service(address_string)
      query = "http://data.wien.gv.at/daten/OGDAddressService.svc/GetAddressInfo?Address=#{address_string}&crs=EPSG:4326"
      uri = URI.parse(URI.encode(query))
      begin
        HTTParty.get(uri)
      rescue
        nil
      end
    end

end
