require 'set'

class Rack::Attack

  ### Logging der geblockten Anfragen
  Rack::Attack.blocklisted_responder = lambda do |req|
    Rails.logger.info "[403 Forbidden | Blocked request: #{req.ip} | path: #{req.fullpath}]"
    [403, { 'Content-Type' => 'text/plain' }, ['403 Forbidden']]
  end

  ### Blockiere typische Exploit-Versuche
  blocklist('block common exploit patterns') do |req|
    req.path =~ %r{
      \.(php|asp|aspx|jsp|cgi|exe|jsf|pl|py|sh|cfm)$   |
      ^/(wp-|\.git|cgi-bin)                           |
      /\/\.env(?:[^\/]*)?                             |
      \/admin-ajax\.php                               |
      \/phpinfo\.php
    }ix
  end

  ### Blockiere gefährliche GET-Requests auf bestimmte Pfade
  blocklist('block GET requests to /attend and /comment_post') do |req|
    req.get? && req.path =~ /\/(attend|comment_post)$/
  end

  ### Blockiere IPs aus ENV
  BLOCKED_IP_SET = Set.new((ENV['BLOCKED_IPS'] || '').split(',').map(&:strip))
  blocklist('block specific IPs') { |req| BLOCKED_IP_SET.include?(req.ip) }

  ### Blockiere SQLi/XSS Signaturen in GET-Requests
  blocklist('block confirmed SQLi/XSS patterns') do |req|
    req.get? && CGI.unescape(req.fullpath.to_s) =~ %r{
      (waitfor\s+delay       |
       benchmark\(           |
       dbms_pipe             |
       \(select\W*.*sleep\(  |
       xor\(.*if\(.*sleep\(  |
       %3Cscript             )
    }ix
  end

end
