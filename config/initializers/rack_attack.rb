require 'set'

class Rack::Attack

  Rack::Attack.blocklisted_responder = lambda do |req|
    # Log blocked request
    Rails.logger.info "[403 Forbidden | Blocked request: #{req.ip} | fullpath: #{req.fullpath}]"
    # Optionally send a custom response
    [403, { 'Content-Type' => 'text/plain' }, ['403 Forbidden']]
  end

  blocklist('block script kiddies') do |req|
    req.path =~ /\.(php|asp|aspx|jsp|cgi|exe|jsf|pl|py|sh|cfm)$/i ||
    req.path&.start_with?('/wp-') ||
    req.path.include?('.git')
  end

  # Block GET requests to /attend and /comment_post
  blocklist('block GET requests to /attend and /comment_post') do |req|
    req.path =~ /\/(attend|comment_post)$/ && req.get?
  end

  # **BLOCKLIST: Bestimmte IP-Adressen**
  BLOCKED_IP_SET = Set.new((ENV['BLOCKED_IPS'] || '').split(',').map(&:strip))
  blocklist('block specific IPs') do |req|
    BLOCKED_IP_SET.include?(req.ip)
  end

  blocklist('block confirmed SQLi/XSS patterns') do |req|
    req.get? && CGI.unescape(req.fullpath.to_s) =~ %r{
      (
        waitfor\s+delay         |
        benchmark\(             |
        dbms_pipe               |
        \(select\W*.*sleep\(    |
        xor\(.*if\(.*sleep\(    |
        %3Cscript
      )
    }ix
  end

end
