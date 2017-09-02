class Rack::Attack

  blocklist('block script kiddies') do |req|
    req.post? && req.path =~ /\.(php|asp|aspx|jsp|cgi)$/i
  end

end
