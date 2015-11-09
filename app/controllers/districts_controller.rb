class DistrictsController < ApplicationController
  def index
    @districts = District.all() unless request.xhr?
    @meetings = Meeting.basic.upcoming.includes([:graetzl]).page(params[:page]).per(15)
    @map_data = GeoJSONService.call(districts: @districts) unless request.xhr?
  end

  def show
    @district = District.find(params[:id])
    @graetzls = @district.graetzls
    @meetings = @district.meetings.basic.upcoming.first(2)
    @locations = @district.locations.approved.order("RANDOM()").first(2)
    @map_data = GeoJSONService.call(districts: @district, graetzls: @graetzls)
  end

  def graetzls
    district = District.find(params[:id])
    render json: district.graetzls.to_json(only: [:id, :name])
  end
end
