class Districts::MeetingsController < ApplicationController
  include DistrictContext

  def index
    set_district
    set_map_data unless request.xhr?
    @meetings = @district.meetings.
      by_currentness.include_for_box.
      page(current_page).per(current_page == 1 ? 14 : 15).
      padding(current_page == 1 ? 0 : -1)
  end

  private

  def current_page
    params[:page] || 1
  end
end
