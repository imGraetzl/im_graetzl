class GraetzlsController < ApplicationController
  def index
    @graetzls = Graetzl.all
  end
  
  def show
    @graetzl = Graetzl.includes(:meetings, :locations).find(params[:id])
    @activities = @graetzl.activity
    @meeting = @graetzl.meetings.basic.upcoming.first
    @locations = @graetzl.locations.managed.order("RANDOM()").first(2)
    @map_data = GeoJSONService.call(graetzls: @graetzl)
  end
end