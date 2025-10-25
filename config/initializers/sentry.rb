# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.traces_sample_rate = 0.2
  config.enabled_environments = %w[production staging]
  config.release = ENV['HEROKU_RELEASE_VERSION'] if ENV['HEROKU_RELEASE_VERSION']

  # nur eigene Logs & evtl. HTTP
  config.breadcrumbs_logger = [:http_logger]
  config.enable_logs = true
  config.rails.structured_logging.enabled = false

  config.rails.report_rescued_exceptions = true

  config.before_send = lambda do |event, hint|
    exc = hint[:exception]
    return nil if exc.is_a?(ActiveRecord::RecordNotFound)
    return nil if exc.is_a?(ActionController::RoutingError)
    return nil if exc.is_a?(ActionController::UnknownFormat)
    event
  end
end
