class GeoJSONService

  FACTORY = RGeo::GeoJSON::EntityFactory.new

  def initialize(args)
    @data = args[:data]
  end

  def feature_collection
    features = []
    @data.each do |d|
      features << FACTORY.feature(d.area, d.id, {})
    end
    RGeo::GeoJSON.encode(FACTORY.feature_collection(features))
  end
end