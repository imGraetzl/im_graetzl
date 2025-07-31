if Rails.env.production? || Rails.env.staging?
  if defined?(Delayed::Worker)
    Delayed::Worker.logger.level = Logger::WARN
  end
end
