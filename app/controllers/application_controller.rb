class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # hide staging app from public
  http_basic_authenticate_with name: 'user', password: 'secret' if Rails.env.staging? && !(ENV["ALLOW_WORKER"] == 'true')

  def after_sign_in_path_for(resource)
    params[:redirect].presence || stored_location_for(resource) || root_url
  end

  def authenticate_admin_user!
    authenticate_user!
    unless current_user.admin?
      flash[:alert] = 'Keine Admin Rechte.'
      redirect_to root_path
    end
  end

  def remember_region
    session[:region_id] = current_region.id if current_region
  end

  helper_method :current_region, :region_root_url, :user_home_graetzl

  def current_region
    if request.host.end_with?(Rails.application.config.welocally_host)
      region_domain = request.host.split(".").first
      Region.get(region_domain)
    elsif request.host.end_with?(Rails.application.config.imgraetzl_host)
      Region.get('wien')
    end
  end

  def region_root_url(region)
    root_url(host: region.host)
  end

  def user_home_graetzl
    current_user.graetzl if current_user && current_user.graetzl.region == current_region
  end

  def redirect_to_region?(record)
    if record.region != current_region
      redirect_to url_for(request.params.merge(host: record.region.host)), :status => 301
    end
  end

end
