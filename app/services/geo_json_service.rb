class GeoJSONService
  include Rails.application.routes.url_helpers

  FACTORY = RGeo::GeoJSON::EntityFactory.new
  ROUTES = Rails.application.routes.url_helpers

  # def initialize(args)
  #   @data = args[:data]
  # end

  def self.district(data, options={})
    features = []
    if data.respond_to?(:size)
      data.each do |d|
        features << FACTORY.feature(d.area, d.id, { targetURL: ROUTES.district_path(d) })
      end
    else
      puts data
      features << FACTORY.feature(data.area, data.id, { targetURL: ROUTES.district_path(data) })
    end
    RGeo::GeoJSON.encode(FACTORY.feature_collection(features))
  end

  def self.graetzl(data, options={})
    features = []
    if data.respond_to?(:size)
      data.each do |d|
        features << FACTORY.feature(d.area, d.id, { targetURL: ROUTES.graetzl_path(d) })
      end
    else
      features << FACTORY.feature(data.area, data.id, { targetURL: ROUTES.graetzl_path(data) })
    end
    RGeo::GeoJSON.encode(FACTORY.feature_collection(features))
  end
end