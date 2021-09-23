class MapData < BaseService

  RGEO_FACTORY = RGeo::GeoJSON::EntityFactory.new

  def encode(areas)
    features = Array(areas).map do |a|
      RGEO_FACTORY.feature(a.area, a.id, {
        id: a.id,
        name: a.name,
        url: area_url(a),
      })
    end
    RGeo::GeoJSON.encode(RGEO_FACTORY.feature_collection(features))
  end

  def encode_favorite_graetzls(areas, favorite_graetzls, home_graetzl)
    features = Array(areas).map do |a|
      RGEO_FACTORY.feature(a.area, a.id, {
        id: a.id,
        name: a.name,
        url: area_url(a),
        plz: plz_prefix(a),
        favorite: Array(favorite_graetzls).include?(a),
        home: Array(home_graetzl).include?(a)
      })
    end
    RGeo::GeoJSON.encode(RGEO_FACTORY.feature_collection(features))
  end

  def plz_prefix(area)
    area.zip ? "#{area.zip} - " : ''
  end

  def area_url(area)
    if area.is_a?(District)
      Rails.application.routes.url_helpers.district_index_path(area)
    elsif area.is_a?(Graetzl)
      Rails.application.routes.url_helpers.graetzl_path(area)
    end
  end

end
