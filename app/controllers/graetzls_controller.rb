class GraetzlsController < ApplicationController
  def index
    @graetzls = Graetzl.all
  end
  
  # def show
  #   unless request.xhr?
  #     @graetzl = Graetzl.includes(:meetings, :locations).find(params[:id])
  #     @meetings = @graetzl.meetings.basic.upcoming.first(2)
  #     @locations = @graetzl.locations.approved.order("RANDOM()").first(2)
  #     @map_data = GeoJSONService.call(graetzls: @graetzl)
  #   end
  #   @activities = @graetzl.activity.page(params[:page]).per(10)
  # end

  def show
    @graetzl = Graetzl.find(params[:id])
    @activities = @graetzl.activity.page(params[:page]).per(10)
    @map_data = GeoJSONService.call(graetzls: @graetzl) unless request.xhr?
  end
end