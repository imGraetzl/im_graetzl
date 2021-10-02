class HomeController < ApplicationController

  def index
    if current_region.nil?
      region = find_best_region
      redirect_to region ? root_url(host: region.host) : about_platform_url and return
    end

    if current_user && user_home_graetzl
      redirect_to user_home_graetzl
    else
      @activity_sample = ActivitySample.new(current_region: current_region)
      render 'region'
    end
  end

  def about
    render 'about', layout: 'platform'
  end

  private

  def find_best_region
    if current_user
      current_user.region
    else
      IpResolver.new.find_region(request.remote_ip)
    end
  end

end
