class StaticPagesController < ApplicationController

  def home
    if current_user
      redirect_to current_user.graetzl
    else
      @meetings = Meeting.by_currentness.first(2)
      @locations = Location.by_activity.to_a.first(2)
      @zuckerls = Zuckerl.order("RANDOM()").first(2)
    end
  end
end
