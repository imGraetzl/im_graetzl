class DistrictsController < ApplicationController
  def index
    @districts = District.all()
    @meetings = Meeting.upcoming.limit(4)
    @map_data = {
      districts: GeoJSONService.district(@districts)
    }.to_json
    #@map_data = GeoJSONService.district(@districts).to_json
    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.json { render json: GeoJSONService.new(data: @districts).feature_collection}
    # end
  end

  def show
    @district = District.find(params[:id])
    @graetzls = @district.graetzls
    @meetings = Meeting.upcoming.where(graetzl: @graetzls).limit(4)
    @map_data = {
      districts: GeoJSONService.district(@district),
      graetzls: GeoJSONService.graetzl(@graetzls),
    }.to_json
  end
end