# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

## ADD GRAETZL DATA TO DB FOR TESTS
Graetzl.destroy_all
geojson = File.read(Rails.root+"public/graetzl.json")
feature_collection = JSON.parse(geojson)['features']

feature_collection.each do |feature|
  polygon = RGeo::GeoJSON.decode(feature['geometry'], :json_parser => :json)
  name = feature['properties']['name']
  Graetzl.create(name: name, area: polygon).save!
end