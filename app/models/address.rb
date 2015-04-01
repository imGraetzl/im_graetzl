class Address < ActiveRecord::Base

  ## ASSOCIATIONS
  belongs_to :user

  ## VALIDATIONS
  validates :coordinates, presence: true
  validates :street_name, presence: true
  validates :city, presence: true

  def match_graetzls
    graetzls = Graetzl.where('ST_CONTAINS(area, :point)', point: coordinates)
    if graetzls.empty?
      graetzls = Graetzl.all
    end
    graetzls
  end


  ## CLASS METHODS
  def self.new_from_geojson(feature)
    point = RGeo::GeoJSON.decode(feature['geometry'], :json_parser => :json)
    Address.new(
      coordinates: point,
      street_name: feature['properties']['StreetName'],
      street_number: feature['properties']['StreetNumber'],
      zip: feature['properties']['PostalCode'],
      city: feature['properties']['Municipality'])    
  end

end
