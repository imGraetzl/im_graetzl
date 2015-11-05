class Districts::LocationsController < ApplicationController

  # Overwrite to match needed js
  def self.controller_name
    'districts'
  end

  def index
    @district = District.find(params[:district_id])
    @locations = @district.locations.approved.page(params[:page]).per(5)
    @map_data = GeoJSONService.call(districts: @district, graetzls: @district.graetzls)
  end
end
