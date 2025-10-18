require 'set'

class Rack::Attack

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

end
