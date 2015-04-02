class Address < ActiveRecord::Base
  # associations
  belongs_to :user

  # validations
  validates :coordinates, presence: true
  validates :street_name, presence: true
  validates :city, presence: true

  # class methods
  def self.new_from_geojson(feature)
    point = RGeo::GeoJSON.decode(feature['geometry'], :json_parser => :json)
    Address.new(
      coordinates: point,
      street_name: feature['properties']['StreetName'],
      street_number: feature['properties']['StreetNumber'],
      zip: feature['properties']['PostalCode'],
      city: feature['properties']['Municipality'])    
  end

  # instance methods
  def match_graetzls
    graetzls = Graetzl.where('ST_CONTAINS(area, :point)', point: coordinates)
    if graetzls.empty?
      graetzls = Graetzl.all
    end
    graetzls
  end

end
