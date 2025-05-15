# frozen_string_literal: true

Sentry.init do |config|
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.dsn = ENV['SENTRY_DSN']
  config.traces_sample_rate = 0.2
  config.enabled_environments = %w[production staging]
end
