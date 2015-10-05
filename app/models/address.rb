class Address < ActiveRecord::Base

  # associations
  belongs_to :addressable, polymorphic: true

  # callbacks
  before_save :get_coordinates unless Rails.env.test?

  # class methods
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
      nil
    end
  end

  def self.attributes_to_reset_location
    a = { coordinates: nil,
      street_name: nil,
      street_number: nil,
      zip: nil,
      city: nil
    }
  end

  # instance methods
  def graetzls
    Graetzl.where('ST_CONTAINS(area, :point)', point: coordinates)
  end

  def graetzl
    graetzls.first
  end

  private

  def get_coordinates
    if (addressable_type == 'Location') && street_name
      coordinates = CoordinatesService.new(self).coordinates
    end
  end
end