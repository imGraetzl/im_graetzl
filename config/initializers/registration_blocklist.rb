# Entries support exact emails (foo@bar.com) or domain wildcards (*@spam.com)
Rails.application.config.registration_email_blocklist = ENV.fetch('REGISTRATION_EMAIL_BLOCKLIST', '')
  .split(',')
  .map { |value| value.strip.downcase }
  .reject(&:blank?)
