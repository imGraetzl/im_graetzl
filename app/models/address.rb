class Address < ActiveRecord::Base

  ## ASSOCIATIONS
  belongs_to :user

  def match_graetzls
    graetzls = Graetzl.where('ST_CONTAINS(area, :point)', point: coordinates)
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
