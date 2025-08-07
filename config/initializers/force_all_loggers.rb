if ENV["RAILS_LOG_TO_STDOUT"].present?
  logger = ActiveSupport::Logger.new(STDOUT)
  logger.level = Logger::DEBUG # damit auch info/debug erscheint!
  logger.formatter = proc do |severity, datetime, progname, msg|
    "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} #{severity}: #{msg}\n"
  end

  # Alle relevanten Logger auf den neuen Logger setzen!
  Rails.logger = logger
  ActiveRecord::Base.logger = logger
  ActionController::Base.logger = logger
  ActionMailer::Base.logger = logger
  # Falls du Sidekiq oder Delayed::Worker nutzt:
  if defined?(Sidekiq)
    Sidekiq::Logging.logger = logger
  end
  if defined?(Delayed::Worker)
    Delayed::Worker.logger = logger
  end
end