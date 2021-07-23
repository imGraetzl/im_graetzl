class StaticPagesController < ApplicationController

  def home
    if current_region.nil? # www.welocally.at
      render 'platform_info', layout: false
    elsif current_user && user_home_graetzl
      redirect_to user_home_graetzl
    else
      @activity_sample = ActivitySample.new(current_region: current_region)
    end
  end

  def robots
    render 'robots.text'
  end

end
