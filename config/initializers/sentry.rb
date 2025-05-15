# frozen_string_literal: true

Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.dsn = ENV['SENTRY_DSN']
  config.traces_sample_rate = 0.2
  config.enable_logs = true
  config.enabled_environments = %w[production staging]

  config.rails.report_rescued_exceptions = true

  config.before_send = lambda do |event, hint|
    exc = hint[:exception]
    return nil if exc.is_a?(ActiveRecord::RecordNotFound)
    return nil if exc.is_a?(ActionController::RoutingError)
    return nil if exc.is_a?(ActionController::UnknownFormat)
    event
  end

end
