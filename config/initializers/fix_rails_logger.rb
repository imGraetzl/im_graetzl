# config/initializers/fix_rails_logger.rb
Rails.application.config.after_initialize do
  if Rails.env.staging? || Rails.env.production?
    # Einfacher STDOUT Logger mit Tagged Logging
    stdout_logger = ActiveSupport::Logger.new(STDOUT)
    stdout_logger.level = ENV.fetch('LOG_LEVEL', 'info') == 'debug' ? Logger::DEBUG : Logger::INFO
    Rails.logger = ActiveSupport::TaggedLogging.new(stdout_logger)
    
    # Alle Rails-Komponenten nutzen denselben Logger
    ActiveRecord::Base.logger = Rails.logger if defined?(ActiveRecord)
    ActionController::Base.logger = Rails.logger if defined?(ActionController)
    ActionView::Base.logger = Rails.logger if defined?(ActionView)
    ActiveJob::Base.logger = Rails.logger if defined?(ActiveJob)
    
    Rails.logger.info "[LOGGER-SETUP] Rails.logger configured for #{Rails.env} with level #{ENV.fetch('LOG_LEVEL', 'info')}"
  end
end