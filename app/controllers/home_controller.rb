class HomeController < ApplicationController

  def index
    if current_region.nil?
      region = find_best_region
      if region
        redirect_to region_root_url(region) and return
      else
        render 'about', layout: 'platform' and return
      end
    end

    if current_user && user_home_graetzl
      redirect_to user_home_graetzl
    else
      remember_region if !current_user
      @activity_sample = ActivitySample.new(current_region: current_region)
      render 'region'
    end
  end

  def about
    render 'about', layout: 'platform'
  end

  def geolocation
    head :bad_request and return if params[:longitude].blank? || params[:latitude].blank?
    region = GeoResolver.new.find_region(params[:longitude], params[:latitude])
    if region && region.id != 'wien'
      render :js => "window.location = '#{region_root_url(region)}'"
    end
  end

  private

  def find_best_region
    if current_user
      current_user.region
    else session[:region_id].present?
      Region.get(session[:region_id])
    #else
      #IpResolver.new.find_region(request.remote_ip)
    end
  end

end
