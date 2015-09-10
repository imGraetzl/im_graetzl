class DistrictsController < ApplicationController
  def index
    @districts = District.all()
    @meetings = Meeting.upcoming.limit(4)
    @map_data = GeoJSONService.call(districts: @districts)
  end

  def show
    @district = District.find(params[:id])
    @graetzls = @district.graetzls
    @meetings = Meeting.upcoming.where(graetzl: @graetzls).limit(4)
    @map_data = GeoJSONService.call(districts: @district, graetzls: @graetzls)
  end
end