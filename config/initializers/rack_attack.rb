class Rack::Attack

  blocklist('block script kiddies') do |req|
    req.path =~ /\.(php|asp|aspx|jsp|cgi)$/i ||
    req.path&.start_with?('wp-content')
  end

end
