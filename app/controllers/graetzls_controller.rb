class GraetzlsController < ApplicationController
  def index
    @graetzls = Graetzl.all
  end
  
  def show
    @graetzl = Graetzl.find(params[:id])
    @activities = @graetzl.activity
    @meeting = @graetzl.meetings.upcoming.first
    @map_data = GeoJSONService.call(graetzls: @graetzl)
  end
end