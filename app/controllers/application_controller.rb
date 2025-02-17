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

  def authenticate_superadmin_user!
    authenticate_user!
    unless current_user.superadmin?
      flash[:alert] = 'Keine Superadmin-Rechte.'
      redirect_to root_path
    end
  end

  def remember_region
    session[:region_id] = current_region.id if current_region
  end

  helper_method :current_region, :region_root_url, :user_home_graetzl, :current_or_session_guest_user

  def current_or_guest_user_by(email)
    return current_user if current_user
  
    email = email.strip.downcase
    user = User.guests.find_by_email(email)
    if user
      session[:guest_user_id] = user.id
      session[:guest_user_created_at] ||= Time.current
      Rails.logger.error("ApplicationController: current_or_guest_user_by: Existing Guest User found for: #{email}")
      return user
    end
  
    guest = create_guest_user
    session[:guest_user_id] = guest.id
    session[:guest_user_created_at] = Time.current
    Rails.logger.error("ApplicationController: current_or_guest_user_by: New Guest User created for: #{email}")
    guest
  rescue => e
    Rails.logger.error("ApplicationController: current_or_guest_user_by: Error occurred - #{e.message}")
    raise # Optional, um den Fehler weiterzugeben
  end

  def current_or_session_guest_user
    current_user || session_guest_user
  end

  def session_guest_user
    User.guests.find_by(id: session[:guest_user_id]) if session[:guest_user_id]
  end

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

  private

  def guest_login_authentication_key(key)
    key &&= nil unless key.to_s.match(/^guest/)
    key ||= "guest_" + 9.times.map { SecureRandom.rand(0..9) }.join
  end

  def manage_guest_user_session
    # Prüfen, ob eine Gast-Session abgelaufen ist und gelöscht werden soll
    if session[:guest_user_id] && session[:guest_user_last_seen_at] && session[:guest_user_last_seen_at].to_time < 15.minutes.ago
      reset_guest_session
    else
      # Aktualisiere den Zeitstempel für die letzte Aktivität oder setze ihn neu
      session[:guest_user_last_seen_at] = Time.current
    end
  end

  def reset_guest_session
    session.delete(:guest_user_id)
    session.delete(:guest_user_last_seen_at)
  end

end
