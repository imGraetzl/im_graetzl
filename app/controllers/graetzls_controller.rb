class GraetzlsController < ApplicationController

  def show
    @graetzl = Graetzl.find(params[:id])
    @map_data = MapData.call(graetzl: @graetzl)

    if !user_signed_in?
      @meetings = @graetzl.meetings.include_for_box.by_currentness.first(2)
      @locations= @graetzl.locations.approved.include_for_box.by_activity.first(2)
      @rooms = @graetzl.room_offers.by_currentness.first(2)
      @zuckerls = @graetzl.zuckerls.include_for_box.order("RANDOM()").first(2)
      @posts = @graetzl.posts.where(type: "UserPost").order(created_at: :desc).first(2)
    end
  end

  def meetings
    @graetzl = Graetzl.find(params[:id])
    @map_data = MapData.call(graetzl: @graetzl)
  end

  def locations
    @graetzl = Graetzl.find(params[:id])
    @map_data = MapData.call(graetzl: @graetzl)
  end

  def rooms
    @graetzl = Graetzl.find(params[:id])
    @map_data = MapData.call(graetzl: @graetzl)
  end

  def zuckerls
    @graetzl = Graetzl.find(params[:id])
    @map_data = MapData.call(graetzl: @graetzl)
  end

  def posts
    @graetzl = Graetzl.find(params[:id])
    @map_data = MapData.call(graetzl: @graetzl)
  end

end
