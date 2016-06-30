class MapData < BaseService
  # TODO: set path...

  def initialize(districts:nil, district:nil, graetzls:nil, graetzl:nil)
    districts = [districts, district].flatten.compact
    graetzls = [graetzls, graetzl].flatten.compact

    # want to end up with two only collections here
    @districts = districts.empty? ? nil : districts
    @graetzls = graetzls.empty? ? nil : graetzls
  end

  def call
    map_hash.to_json
  end

  private

  attr_reader :districts, :graetzls

  def map_hash
    [district_data, graetzl_data].inject(:merge)
  end

  def district_data
    return {} unless @districts
    { districts: encode(@districts) }
  end

  def graetzl_data
    return {} unless @graetzls
    { graetzls: encode(@graetzls) }
  end

  def encode(collection)
    features = collection.map{ |item| feature item }
    feature_collection = factory.feature_collection features
    RGeo::GeoJSON.encode feature_collection
  end

  def feature(item)
    factory.feature(item.area, item.id, properties(item))
  end

  def properties(item)
    { name: item.name, zip: item.try(:zip), targetURL: polymorphic_path(item) }
  end

  def factory
    @factory ||= RGeo::GeoJSON::EntityFactory.new
  end
end
