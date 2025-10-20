require "digest"

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception  
  before_action :set_sentry_user_context

  # hide staging app from public
  before_action :maybe_authenticate

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
      Rails.logger.info("[ApplicationController]: current_or_guest_user_by: Existing Guest User found for: #{email}")
      return user
    end
  
    guest = create_guest_user
    session[:guest_user_id] = guest.id
    session[:guest_user_created_at] = Time.current
    Rails.logger.info("[ApplicationController]: current_or_guest_user_by: New Guest User created for: #{email}")

    guest
  rescue => e
    Rails.logger.error("[ApplicationController]: current_or_guest_user_by: Error occurred - #{e.message}")
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
      redirect_to(
        url_for(request.params.merge(host: record.region.host)),
        status: 301,
        allow_other_host: true
      )
      return true
    end
    false
  end

  protected

  def set_schema_org_object(obj)
    @schema_org_object = obj
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

  def set_sentry_user_context
    if current_user
      Sentry.set_user(
        id: current_user.id,
        segment: "user"
      )
    elsif session[:guest_user_id]
      Sentry.set_user(
        id: session[:guest_user_id],
        segment: "guest"
      )
    end
  end

  def maybe_authenticate
    # Staging Basic Auth
    return unless Rails.env.staging?
    return if ENV["STAGING_AUTH_DISABLED"].present?
    # Paths, die KEIN Basic Auth brauchen
    allowed_prefixes = [
      '/assets',        # alle normalen Assets (Sprockets oder Webpacker)
      '/packs',         # Webpacker-Assets
      '/favicon.ico'
    ]
    return if allowed_prefixes.any? { |p| request.path.starts_with?(p) }

    username = ENV.fetch('STAGING_AUTH_USER', 'user')
    password = ENV.fetch('STAGING_AUTH_PASSWORD', 'secret')

    authenticate_or_request_with_http_basic('Application') do |name, pass|
      ActiveSupport::SecurityUtils.secure_compare(name, username) &&
        ActiveSupport::SecurityUtils.secure_compare(pass, password)
    end
  end

  def handle_rate_limit!(retry_after: 60)
    identity = rate_limit_identity
    cache_key = "rate-limit:notify:#{identity}:#{controller_path}"
    expiry = [retry_after, 120].max
    count = Rails.cache.increment(cache_key, 1, expires_in: expiry, initial: 1)
    count ||= 1

    if count == 1
      Sentry.capture_message(
        "Rate limit hit",
        level: :warning,
        extra: {
          ip: request.remote_ip,
          path: request.fullpath,
          ua: request.user_agent
        }
      )
      Rails.logger.warn("[RateLimit] ip=#{request.remote_ip} path=#{request.fullpath} ua=#{request.user_agent}")
    elsif (count % 30).zero?
      Rails.logger.warn("[RateLimitBurst] controller=#{controller_path} ip=#{request.remote_ip} ua=#{request.user_agent} count=#{count} window=#{expiry}s")
    end

    response.set_header('Retry-After', retry_after.to_s)
    head :too_many_requests
  end

  def rate_limit_identity
    ua = request.user_agent.to_s
    if ua.present?
      digest = Digest::SHA1.hexdigest(ua)[0, 12]
      "ip:#{request.remote_ip}:ua:#{digest}"
    else
      "ip:#{request.remote_ip}"
    end
  end

end
