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

  helper_method :current_region, :user_home_graetzl

  def current_region
    if request.domain.end_with?('welocally.at')
      region_domain = request.subdomain.split(".").first
      Region.get(region_domain)
    else
      Region.get('wien')
    end
  end

  def user_home_graetzl
    current_user.graetzl if current_user && current_user.graetzl.region == current_region
  end

end
