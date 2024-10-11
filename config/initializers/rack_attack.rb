class Rack::Attack

  Rack::Attack.blocklisted_responder = lambda do |req|
    # Log blocked request
    Rails.logger.info "[403 Forbidden | Blocked request: #{req.ip} for path #{req.path}]"
    # Optionally send a custom response
    [403, { 'Content-Type' => 'text/plain' }, ['403 Forbidden']]
  end

  blocklist('block script kiddies') do |req|
    req.path =~ /\.(php|asp|aspx|jsp|cgi|exe|jsf)$/i ||
    req.path&.start_with?('/wp-content')
  end

  # Block GET requests to /attend and /comment_post
  blocklist('block GET requests to /attend and /comment_post') do |req|
    req.path =~ /\/(attend|comment_post)$/ && req.get?
  end

end
