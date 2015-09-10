class GraetzlsController < ApplicationController
  def index
    @graetzls = Graetzl.all
  end
  
  def show
    @graetzl = Graetzl.find(params[:id])
    @activities = @graetzl.activity
    @meetings = @graetzl.meetings.upcoming.first(2)
    @map_data = {
      graetzls: GeoJSONService.graetzl(@graetzl),
    }.to_json
  end
end