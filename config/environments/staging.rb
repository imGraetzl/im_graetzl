require "active_support/core_ext/integer/time"

Rails.application.configure do
  # --- Security & Performance ---
  config.middleware.insert_before 0, Rack::Attack

  # --- App-spezifisch ---
  config.stripe_default_tax_rates = "txr_1NzlODESnSu3ZRERf9VJorBc"
  config.imgraetzl_host = "staging.imgraetzl.at"
  config.welocally_host = "staging.welocally.at"
  config.platform_admin_email = 'michael@imgraetzl.at'

  # --- Code loading & Caching ---
  config.cache_classes = true
  config.eager_load = true

  # --- Error Reporting ---
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
  config.asset_host = 'https://assets-staging-app.welocally.at'

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

  # Use a different cache store in production.
  config.cache_store = :redis_cache_store, {
    url: ENV.fetch("REDIS_URL"),
    namespace: "imgraetzl:cache:stg:v1",
    connect_timeout: 2,
    read_timeout: 1,
    write_timeout: 1,
    pool: { size: Integer(ENV.fetch("RAILS_MAX_THREADS", 3)), timeout: 1 },
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }, # <— wichtig für Mini
    error_handler: -> (method:, returning:, exception:) {
      Rails.logger.warn("Redis cache error #{method}: #{exception.class} #{exception.message}")
    }
  }

  # Optional fürs Debugging:
  config.action_controller.enable_fragment_cache_logging = true


  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  config.action_mailer.raise_delivery_errors = true

  # Mailer config
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_caching = false
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
  config.x.mandril_from_name = 'staging.imGrätzl.at'
  config.x.mandril_from_email = 'staging-no-reply@imgraetzl.at'

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Log disallowed deprecations.
  config.active_support.disallowed_deprecation = :log

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # --- Logging ---
  config.log_level = ENV.fetch('LOG_LEVEL', 'info').to_sym  # Gleich wie Production!
  config.log_tags = [:request_id, -> request { "staging" }]  # Mit staging Tag
  config.log_formatter = ::Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Use delayed jobs
  config.active_job.queue_adapter = :delayed_job

  # Whitelist für alle genutzten Domains & Subdomains (wie in production.rb!)
  config.hosts << /.*\.welocally\.at/
  config.hosts << "welocally.at"
  config.hosts << /.*\.imgraetzl\.at/
  config.hosts << "imgraetzl.at"

end
