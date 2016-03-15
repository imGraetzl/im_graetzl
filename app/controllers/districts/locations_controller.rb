class Districts::LocationsController < ApplicationController
  include DistrictContext

  def index
    set_district
    @locations = @district.locations.approved.includes(:address, :category, :graetzl).
      page(params[:page]).
      per(params[:page].blank? ? 14 : 15).
      padding(params[:page].blank? ? 0 : -1)
    set_map_data unless request.xhr?
  end
end
