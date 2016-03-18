class GraetzlsController < ApplicationController
  def show
    @graetzl = Graetzl.find(params[:id])
    current_user ? user_content : guest_content
  end

  private

  def user_content
    @activity = @graetzl.activity.page(params[:page]).per(12)
    unless request.xhr?
      @activity_decorated = @graetzl.decorate_activity @activity
      @map_data = GeoJSONService.call(graetzls: @graetzl)
    end
  end

  def guest_content
    @meetings = @graetzl.meetings.by_currentness.first(2)
    @locations = @graetzl.locations.approved.order("RANDOM()").first(2)
    @zuckerls = @graetzl.zuckerls.order("RANDOM()").first(2)
    @posts = @graetzl.posts.order("RANDOM()").first(2)
    @map_data = GeoJSONService.call(graetzls: @graetzl)
  end
end
