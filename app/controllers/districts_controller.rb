class DistrictsController < ApplicationController
  def index
    @districts = District.all()
    @meetings = Meeting.upcoming.limit(4)
    @map_data = GeoJSONService.new(data: @districts).feature_collection
    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.json { render json: GeoJSONService.new(data: @districts).feature_collection}
    # end
  end

  def show
    @district = District.find(params[:id])
    @meetings = Meeting.upcoming.where(graetzl: @district.graetzls).limit(4)
  end
end