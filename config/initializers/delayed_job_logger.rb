# frozen_string_literal: true

if Rails.env.production? || Rails.env.staging?
  if defined?(Delayed::Worker)
    # Eigener Logger nur für Delayed Job
    dj_logger = ActiveSupport::Logger.new($stdout)
    dj_logger.formatter = Rails.application.config.log_formatter
    dj_logger.level = Logger::WARN

    Delayed::Worker.logger = dj_logger

    Rails.logger.info "[DelayedJobLogger] Initialized separate DJ logger with level WARN"
  end
end
