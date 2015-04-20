namespace :db do
  desc "import graetzl from geojson"
  task import_graetzl: :environment do
    Graetzl.destroy_all
    geojson = File.read(Rails.root+"public/graetzl.json")
    feature_collection = JSON.parse(geojson)['features']

    feature_collection.each do |feature|
      polygon = RGeo::GeoJSON.decode(feature['geometry'], :json_parser => :json)
      name = feature['properties']['name']
      Graetzl.create(name: name, area: polygon).save!
    end
  end
end