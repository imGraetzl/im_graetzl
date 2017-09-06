class DistrictsController < ApplicationController
  def index
    @meetings = Meeting.upcoming.include_for_box.page(params[:page]).per(15)
    unless request.xhr?
      @districts = District.all
      @map_data = MapData.call districts: @districts
    end
  end

  def show
    set_district
    @meetings = @district.meetings.include_for_box.by_currentness.first(2)
    @locations = @district.locations.approved.include_for_box.by_activity.first(2)
    @zuckerls = @district.zuckerls.order("RANDOM()").first(2)
    @map_data = MapData.call district: @district, graetzls: @district.graetzls
  end

  def graetzls
    set_district
    render json: @district.graetzls.to_json(only: [:id, :name])
  end

  private

  def set_district
    @district = District.find(params[:id])
  end
end
