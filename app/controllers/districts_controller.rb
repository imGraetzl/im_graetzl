class DistrictsController < ApplicationController
  def index
    @meetings = Meeting.upcoming.
      includes([:graetzl]).
      page(params[:page]).per(15)
    unless request.xhr?
      @districts = District.all()
      @map_data = GeoJSONService.call(districts: @districts)
    end
  end

  def show
    set_district
    graetzls = @district.graetzls
    @meetings = @district.meetings.by_currentness.first(2)
    @locations = @district.locations.by_activity.to_a.first(2)
    @zuckerls = @district.zuckerls.order("RANDOM()").first(2)
    @map_data = GeoJSONService.call(districts: @district, graetzls: graetzls)
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
