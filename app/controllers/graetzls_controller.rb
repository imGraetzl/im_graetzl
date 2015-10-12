class GraetzlsController < ApplicationController
  def index
    @graetzls = Graetzl.all
  end

  def show
    @graetzl = Graetzl.find(params[:id])
    @activities = @graetzl.activity.page(params[:page]).per(10)
    @map_data = GeoJSONService.call(graetzls: @graetzl) unless request.xhr?
  end
end