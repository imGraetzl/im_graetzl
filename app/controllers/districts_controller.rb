class DistrictsController < ApplicationController
  def index
    @districts = District.all()
    @meetings = Meeting.basic.upcoming.limit(60).includes([:graetzl])
    @map_data = GeoJSONService.call(districts: @districts)
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
