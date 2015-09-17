class GraetzlsController < ApplicationController
  def index
    @graetzls = Graetzl.all
  end
  
  def show
    @graetzl = Graetzl.includes(:meetings, :locations).find(params[:id])
    @activities = @graetzl.activity
    @meetings = @graetzl.meetings.basic.upcoming.first(2)
    @locations = @graetzl.locations.managed.order("RANDOM()").first(2)
    @map_data = GeoJSONService.call(graetzls: @graetzl)
  end
end