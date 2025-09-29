# config/initializers/fix_rails_logger.rb

if Rails.env.staging? || Rails.env.production?
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    level = case ENV.fetch('LOG_LEVEL', 'info').to_s.downcase
            when 'debug' then :debug
            when 'info'  then :info
            when 'warn'  then :warn
            when 'error' then :error
            else :info
            end

    logger = ActiveSupport::Logger.new($stdout)
    logger.level = ActiveSupport::Logger.const_get(level.to_s.upcase)
    logger.formatter = Rails.application.config.log_formatter

    Rails.logger = ActiveSupport::TaggedLogging.new(logger)

    # auch für Subsysteme
    ActiveRecord::Base.logger = Rails.logger if defined?(ActiveRecord)
    ActionController::Base.logger = Rails.logger if defined?(ActionController)
    ActionView::Base.logger = Rails.logger if defined?(ActionView)
    ActiveJob::Base.logger = Rails.logger if defined?(ActiveJob)

    Rails.logger.warn "[LOGGER] Initialized for #{Rails.env} with level #{level}"
  end
end
