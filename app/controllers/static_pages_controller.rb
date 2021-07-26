class StaticPagesController < ApplicationController

  layout :set_layout

  def home
    if current_region.nil?
      render 'platform_info'
    elsif current_user && user_home_graetzl
      redirect_to user_home_graetzl
    else
      @activity_sample = ActivitySample.new(current_region: current_region)
    end
  end

  def robots
    render 'robots.text'
  end

  private

  def set_layout
    if current_region.nil?
      'platform'
    else
      'application'
    end
  end

end
