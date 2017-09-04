class StaticPagesController < ApplicationController

  def home
    if current_user
      redirect_to current_user.graetzl
    else
      @meetings = Meeting.include_for_box.by_currentness.first(2)
      @locations = Location.by_activity.first(2)
      @zuckerls = Zuckerl.live.includes(location: [:graetzl, :category, :address]).order("RANDOM()").first(2)
    end
  end

end
