class Districts::LocationsController < ApplicationController
  include DistrictContext

  def index
    set_district
    @locations = @district.locations.approved.include_for_box.
      page(current_page).per(current_page == 1 ? 14 : 15).
      padding(current_page == 1 ? 0 : -1)
    set_map_data unless request.xhr?
  end

  private

  def current_page
    params[:page] || 1
  end

end
