class DistrictsController < ApplicationController
  def index
    @districts = District.all()
    @meetings = Meeting.basic.upcoming.limit(60)
    @map_data = GeoJSONService.call(districts: @districts)
  end

  def show
    @district = District.find(params[:id])
    @graetzls = @district.graetzls
    @meetings = Meeting.basic.upcoming.where(graetzl: @graetzls).limit(60)
    @map_data = GeoJSONService.call(districts: @district, graetzls: @graetzls)
  end

  def graetzls
    district = District.find(params[:id])
    render json: district.graetzls.to_json(only: [:id, :name])
  end
end