require 'set'

class Rack::Attack

  # Statische Assets etc. sollen die Limits nicht triggern
  THROTTLE_EXCLUDED_PREFIXES = %w[/assets /packs /static-assets /favicon.ico].freeze

  # 403-Responder mit erweitertem Logging
  Rack::Attack.blocklisted_responder = lambda do |req|
    payload = {
      status:          403,
      event:           "rack_attack_block",
      method:          req.request_method,
      path:            req.path,
      fullpath:        req.fullpath,
      host:            req.host,
      ip:              req.ip,
      forwarded_for:   req.get_header('HTTP_X_FORWARDED_FOR'),
      user_agent:      req.user_agent&.slice(0, 200),
      referer:         req.referer,
      content_type:    req.get_header('CONTENT_TYPE'),
      content_length:  req.get_header('CONTENT_LENGTH'),
      request_id:      req.get_header('action_dispatch.request_id'),
      heroku_request_id: req.get_header('HTTP_HEROKU_REQUEST_ID')
    }.compact

    safe_payload = payload.transform_values do |value|
      next value unless value.is_a?(String)
      value.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
    end

    Rails.logger.warn("[RA_BLOCK] " + safe_payload.to_json)

    [403, { 'Content-Type' => 'text/plain' }, ['403 Forbidden']]
  end

  ### Blockiere typische Exploit-Versuche
  blocklist('block common exploit patterns') do |req|
    req.path =~ %r{
      \.(php|asp|aspx|jsp|cgi|exe|jsf|pl|py|sh|cfm)$ |
      (?:^|/)(?:wp-|\.git|cgi-bin)(?:/|$)            |
      (?:
        (?:^|/)\.env[^/]*$                           |
        \.env(?:\.[^/]+)?$
      )                                              |
      /admin-ajax\.php$                              |
      /phpinfo\.php$
    }ix
  end

  ### Blockiere gefährliche GET-Requests auf bestimmte Pfade
  blocklist('block GET requests to /attend and /comment_post') do |req|
    req.get? && req.path =~ /\/(attend|comment_post)$/
  end

  ### Blockiere Archiv-Downloads
  blocklist('block archive requests: .zip') do |req|
    path = req.path.to_s
    path.match?(/\.zip\z/i)
  end

  ### Blockiere IPs aus ENV
  BLOCKED_IP_SET = Set.new((ENV['BLOCKED_IPS'] || '').split(',').map(&:strip))
  blocklist('block specific IPs') { |req| BLOCKED_IP_SET.include?(req.ip) }

    ### Blockiere SQLi/XSS Signaturen in GET-Requests
    blocklist('block confirmed SQLi/XSS patterns') do |req|
      begin
        # Falls fullpath ungültige Byte-Sequenzen enthält, fangen wir ArgumentError ab
        req.get? && CGI.unescape(req.fullpath.to_s) =~ %r{
          (waitfor\s+delay       |
          benchmark\(           |
          dbms_pipe             |
          \(select\W*.*sleep\(  |
          xor\(.*if\(.*sleep\(  |
          %3Cscript             )
        }ix
      rescue ArgumentError
        # Im Fall von invalid byte sequences: nicht blocken (kein 500), einfach false
        false
      end
    end

  ### Blockiere .js/.css außerhalb von erlaubten Pfaden
  blocklist('block js/css outside allowed paths') do |req|
    req.path =~ /\.(js|css)$/ && 
    !req.path.start_with?('/assets/') && 
    !req.path.start_with?('/static-assets/') &&
    !req.path.start_with?('/delayed_job')
  end

  ### Burst-Limit: 80 Requests / 60 Sekunden (stoppt sehr schnelle Abfolgen)
  throttle('req/ip/burst', limit: 80, period: 60.seconds) do |req|
    next if req.ip.blank?
    next if THROTTLE_EXCLUDED_PREFIXES.any? { |prefix| req.path.start_with?(prefix) }
    req.ip
  end

  ### Dauer-Limit: 1500 Requests / 15 Minuten (begrenzt dauerhaft hohes Volumen)
  throttle('req/ip/steady', limit: 1500, period: 15.minutes) do |req|
    next if req.ip.blank?
    next if THROTTLE_EXCLUDED_PREFIXES.any? { |prefix| req.path.start_with?(prefix) }
    req.ip
  end

  # Liefert konventionelle RateLimit-* Header (siehe Rack::Attack GitHub README)
  Rack::Attack.throttled_responder = lambda do |request|
    match_data = request.env['rack.attack.match_data'] || {}
    now = match_data[:epoch_time] || Time.now.to_i
    limit = (match_data[:limit] || 0).to_i
    period = (match_data[:period] || 60).to_i
    count = (match_data[:count] || 0).to_i

    # Reset-Zeitpunkt gemäß Doku: aktueller Epoch + verbleibende Periodendauer
    reset = now + (period - now % period)
    retry_after = [reset - now, 0].max

    headers = {
      'Content-Type' => 'text/plain; charset=utf-8',
      'RateLimit-Limit' => limit.to_s,
      'RateLimit-Remaining' => [limit - count, 0].max.to_s,
      'RateLimit-Reset' => reset.to_s,
      'Retry-After' => retry_after.to_s,
    }

    # Kurzer Body (RFC-konform, minimal)
    [429, headers, ["Throttled\n"]]
  end

end

# Ergänze Logging für ausgelöste Throttles (identifiziert exakt, welches Limit gegriffen hat)
ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _id, payload|
  req = payload[:request]
  next unless req
  match_data = req.env["rack.attack.match_data"] || {}

  data = {
    event: "rack_attack_throttle",
    throttle: req.env["rack.attack.matched"],
    match_type: req.env["rack.attack.match_type"],
    limit: match_data[:limit],
    count: match_data[:count],
    period: match_data[:period],
    method: req.request_method,
    path: req.path,
    fullpath: req.fullpath,
    host: req.host,
    ip: req.ip,
    forwarded_for: req.get_header('HTTP_X_FORWARDED_FOR'),
    user_agent: req.user_agent&.slice(0, 200),
    request_id: req.get_header('action_dispatch.request_id')
  }.compact

  safe_data = data.transform_values do |value|
    next value unless value.is_a?(String)
    value.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
  end

  Rails.logger.warn("[RA_THROTTLE] " + safe_data.to_json)

  # Temporarily send throttle hits to Sentry as well; remove later if too noisy.
  Sentry.capture_message(
    "Rack::Attack throttle hit (ip=#{safe_data[:ip]})",
    level: :warning,
    extra: safe_data,
    fingerprint: ['rack_attack', safe_data[:throttle], safe_data[:ip]]
  )
end
