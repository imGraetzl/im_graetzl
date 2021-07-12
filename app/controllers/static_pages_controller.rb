class StaticPagesController < ApplicationController

  def home
    if current_user
      redirect_to current_user.graetzl
    else
      @activity_sample = ActivitySample.new(current_region: current_region)
    end
  end

  def robots
    render 'robots.text'
  end

end
