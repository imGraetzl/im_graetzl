require "active_support/core_ext/integer/time"

Rails.application.configure do

  # Prerender Rails for Rendertron, needs PRERENDER_SERVICE_URL
  config.middleware.use Rack::Prerender, whitelist: [
    '^/region/', '/category/',
    '/treffen$', '/locations$', '/coop-share$', '/raumteiler$', '/toolteiler$', '/crowdfunding$', '/zuckerl$'
  ]

  # Settings specified here will take precedence over those in config/application.rb.
  config.imgraetzl_host = "imgraetzl.at"
  config.welocally_host = "welocally.at"

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :terser
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Use welocally.at for assets
  config.asset_host = 'https://www.welocally.at'

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # This will affect assets served from /app/assets
  config.static_cache_control = 'public, max-age=31536000'

  # This will affect assets in /public, e.g. webpacker assets.
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=31536000',
    'Expires' => 1.year.from_now.to_formatted_s(:rfc822)
  }

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  config.action_mailer.raise_delivery_errors = true

  # Mailer config
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: 'smtp.mandrillapp.com',
    port: 587,
    enable_starttls_auto: true,
    user_name: ENV['MANDRILL_USER'],
    password: ENV['MANDRILL_KEY'],
    authentication: :login,
    domain: 'imgraetzl.at',
  }

  # mandrill config
  config.x.mandril_from_name = 'imGrätzl.at'
  config.x.mandril_from_email = 'no-reply@imgraetzl.at'

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Log disallowed deprecations.
  config.active_support.disallowed_deprecation = :log

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
