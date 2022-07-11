class Rack::Attack

  blocklist('block script kiddies') do |req|
    req.path =~ /\.(php|asp|aspx|jsp|cgi)$/i ||
    req.path&.start_with?('wp-content')
  end

  blocklist('block blacklisted IPs') do |req|
    req.ip == '185.242.85.222'
  end

end
