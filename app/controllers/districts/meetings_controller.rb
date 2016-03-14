class Districts::MeetingsController < ApplicationController
  include DistrictContext

  def index
    set_district
    set_map_data unless request.xhr?
    @meetings = @district.meetings.basic.
      order('CASE WHEN starts_at_date > now() THEN 0 WHEN starts_at_date IS NULL THEN 1 ELSE 2 END').
      order(starts_at_date: :desc).
      page(params[:page]).per(params[:page].blank? ? 14 : 15).padding(params[:page].blank? ? 0 : -1)
  end
end
