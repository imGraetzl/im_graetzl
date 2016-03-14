class Districts::ZuckerlsController < ApplicationController
  # Overwrite to match needed js
  def self.controller_name
    'districts'
  end

  def index
    @district = District.find(params[:district_id])
    @map_data = GeoJSONService.call(districts: @district, graetzls: @district.graetzls)
    @zuckerls = @district.zuckerls.
      page(params[:page]).per(15).
      order("RANDOM()")
  end
end
