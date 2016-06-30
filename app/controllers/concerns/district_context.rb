module DistrictContext
  extend ActiveSupport::Concern

  included do
    def self.controller_name
      'districts'
    end
  end

  private

  def set_district
    @district = District.find(params[:district_id])
  end

  def set_map_data
    @map_data = MapData.call district: @district, graetzls: @district.graetzls
  end
end
