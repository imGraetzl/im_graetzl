class GraetzlsController < ApplicationController
  def show
    @graetzl = Graetzl.find(params[:id])
    @activity = @graetzl.activity.page(params[:page]).per(12)
    unless request.xhr?
      @activity_decorated = @graetzl.decorate_activity @activity
      @map_data = GeoJSONService.call(graetzls: @graetzl)
    end
  end
end
