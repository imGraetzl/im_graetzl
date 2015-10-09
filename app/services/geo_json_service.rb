class GeoJSONService
  FACTORY = RGeo::GeoJSON::EntityFactory.new
  ROUTES = Rails.application.routes.url_helpers

  def self.call(districts: nil, graetzls: nil)
    new().map_data(districts, graetzls)
  end

  def map_data(districts, graetzls)
    {
      districts: (feature_collection(districts) if districts),
      graetzls: (feature_collection(graetzls) if graetzls)
    }.to_json    
  end

  private

  def feature_collection(data)
    feature_for = get_feature_type(data)

    features = []
    if data.respond_to?(:size)
      data.each do |d|
        features << feature_for.call(d)
      end
    else
      features << feature_for.call(data)
    end
    RGeo::GeoJSON.encode(FACTORY.feature_collection(features))
    
  end

  def get_feature_type(data)
    # TODO: maybe change to switch syntax
    if data.model_name.human == District.model_name.human
      lambda do |resource|
        FACTORY.feature(resource.area,
                        resource.id,
                        { name: resource.name,
                          zip: resource.zip,
                          targetURL: ROUTES.district_path(resource) })
      end
    else
      lambda do |resource|
        FACTORY.feature(resource.area,
                        resource.id,
                        { name: resource.name,
                          targetURL: ROUTES.graetzl_path(resource) })
      end
    end
  end
end