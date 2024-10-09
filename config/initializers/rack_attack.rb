class Rack::Attack

  Rack::Attack.blocklisted_responder = lambda do |req|
    # Log blocked request
    Rails.logger.info "[Blocked request: #{req.ip} for path #{req.path}]"
    # Optionally send a custom response
    [503, { 'Content-Type' => 'text/plain' }, ['Blocked']]
  end

  blocklist('block script kiddies') do |req|
    req.path =~ /\.(php|asp|aspx|jsp|cgi)$/i ||
    req.path&.start_with?('/wp-content')
  end

  #blocklist('block blacklisted IPs') do |req|
  #  req.ip == '185.242.85.222'
  #end

end
