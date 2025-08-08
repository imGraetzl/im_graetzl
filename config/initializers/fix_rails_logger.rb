# config/initializers/fix_rails_logger.rb

Rails.application.config.after_initialize do
  if Rails.env.staging? || Rails.env.production?
    # Fix für Rails 7.2 BroadcastLogger Issue
    if ENV["RAILS_LOG_TO_STDOUT"].present?
      # Logger Level aus ENV
      level = case ENV.fetch('LOG_LEVEL', 'info').to_s.downcase
      when 'debug' then Logger::DEBUG
      when 'info'  then Logger::INFO
      when 'warn'  then Logger::WARN
      when 'error' then Logger::ERROR
      else Logger::INFO
      end
      
      # Erstelle neuen STDOUT Logger
      stdout_logger = ActiveSupport::Logger.new(STDOUT)
      stdout_logger.level = level
      stdout_logger.formatter = Rails.application.config.log_formatter
      
      # Ersetze Rails.logger
      Rails.logger = ActiveSupport::TaggedLogging.new(stdout_logger)
      
      # Setze für alle Rails-Komponenten
      ActiveRecord::Base.logger = Rails.logger if defined?(ActiveRecord)
      ActionController::Base.logger = Rails.logger if defined?(ActionController)
      ActionView::Base.logger = Rails.logger if defined?(ActionView)
      ActiveJob::Base.logger = Rails.logger if defined?(ActiveJob)
      
      Rails.logger.info "[LOGGER] Initialized for #{Rails.env} with level #{ENV.fetch('LOG_LEVEL', 'info')}"
    end
  end
end