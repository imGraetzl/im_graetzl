class Rack::Attack

  # Log when a request is blocked
  ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, payload|
    req = payload[:request]
    
    # Log blocked requests
    if req.env['rack.attack.match_type'] == :blocklist
      Rails.logger.info "[Rack::Attack][Blocked] Request blocked: #{req.path}, IP: #{req.ip}, User-Agent: #{req.user_agent}"
    end
  end

  blocklist('block script kiddies') do |req|
    req.path =~ /\.(php|asp|aspx|jsp|cgi)$/i ||
    req.path&.start_with?('wp-content')
  end

  blocklist('block blacklisted IPs') do |req|
    req.ip == '185.242.85.222'
  end

end
