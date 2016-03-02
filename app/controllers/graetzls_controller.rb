class GraetzlsController < ApplicationController
  def show
    @graetzl = Graetzl.find(params[:id])
    @activities = Kaminari.paginate_array(@graetzl.activity).page(params[:page]).per(10)
    @map_data = GeoJSONService.call(graetzls: @graetzl) unless request.xhr?
  end
  # def show
  #   @graetzl = Graetzl.find(params[:id])
  #   @feed_items = @graetzl.feed_items(params[:page] || 1)
  #   @map_data = GeoJSONService.call(graetzls: @graetzl) unless request.xhr?
  # end
end
