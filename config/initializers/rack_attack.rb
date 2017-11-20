class Rack::Attack

  blocklist('block script kiddies') do |req|
    (req.post? && req.path =~ /\.(php|asp|aspx|jsp|cgi)$/i) ||
    (req.get? && req.path =~ /wp-login\.php$/)
  end

end
