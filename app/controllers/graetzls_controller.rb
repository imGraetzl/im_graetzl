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
      @map_data = MapData.call graetzl: @graetzl
    end
  end

  def guest_content
    @meetings = @graetzl.meetings.include_for_box.by_currentness.first(2)
    @locations= @graetzl.locations.approved.include_for_box.by_activity.first(2)
    @zuckerls = @graetzl.zuckerls.order("RANDOM()").first(2)
    @posts = @graetzl.posts.where(type: "UserPost").order(created_at: :desc).first(2)
    @map_data = MapData.call graetzl: @graetzl
  end
end
