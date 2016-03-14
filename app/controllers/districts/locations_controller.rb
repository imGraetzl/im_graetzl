class Districts::LocationsController < ApplicationController
  include DistrictContext

  def index
    @district = District.find(params[:district_id])
    @locations = @district.locations.approved.includes(:address, :category, :graetzl).paginate_index(params[:page] || 1)
    @map_data = GeoJSONService.call(districts: @district, graetzls: @district.graetzls) unless request.xhr?
  end
end
