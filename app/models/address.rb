class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  before_save :get_coordinates

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

  def graetzls
    Graetzl.where('ST_CONTAINS(area, :point)', point: coordinates)
  end

  def graetzl
    graetzls.first
  end

  def district_nr
    zip.slice(1..2).sub(%r{^0},"") unless zip.blank?
  end

  private

  def get_coordinates
    if (street_name && addressable_type == 'Location')
      self.coordinates = Coordinates.call(self)
    end
  end
end
