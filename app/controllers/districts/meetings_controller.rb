class Districts::MeetingsController < ApplicationController
  include DistrictContext

  def index
    set_district
    set_map_data unless request.xhr?
    @meetings = @district.meetings.
      by_currentness.
      includes(:graetzl).
      page(params[:page]).per(params[:page].blank? ? 14 : 15).
      padding(params[:page].blank? ? 0 : -1)
  end
end
