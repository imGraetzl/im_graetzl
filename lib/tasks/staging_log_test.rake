namespace :staging do
  desc "Test staging logging configuration"
  task log_test: :environment do
    puts "Testing Staging Logs..."
    puts "Environment: #{ENV['RAILS_ENV']}"
    puts "App Name: #{ENV['HEROKU_APP_NAME']}"
    puts "Log Level: #{Rails.logger.level}"
    
    Rails.logger.debug "[STAGING-TEST] Debug level"
    Rails.logger.info "[STAGING-TEST] Info level"  
    Rails.logger.warn "[STAGING-TEST] Warn level"
    Rails.logger.error "[STAGING-TEST] Error level"
    
    # Test mit deinem Code-Stil
    Rails.logger.warn "[stripe] TEST: Payment warning in staging"
    Rails.logger.error "[stripe] TEST: Payment error in staging"
    
    puts "Check BetterStack for these test messages!"
  end
end