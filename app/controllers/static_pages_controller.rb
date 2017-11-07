class StaticPagesController < ApplicationController

  def home
    if current_user
      redirect_to current_user.graetzl
    else
      @meetings = Meeting.include_for_box.by_currentness.first(2)
      @locations = Location.approved.include_for_box.by_activity.first(2)
      @zuckerls = Zuckerl.live.include_for_box.order("RANDOM()").first(2)
      @rooms= [RoomOffer.order("RANDOM()").first] + [RoomDemand.order("RANDOM()").first]
    end
  end

  def robots
    render 'robots.text'
  end

end
