class Districts::LocationsController < ApplicationController
  include DistrictContext

  def index
    set_district
    @locations = @district.locations.approved.includes(:address, :category, :graetzl).paginate_index(params[:page] || 1)
    set_map_data unless request.xhr?
  end
end
