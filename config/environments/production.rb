require "active_support/core_ext/integer/time"

Rails.application.configure do
  # --- Security & Performance ---
  config.middleware.insert_before 0, Rack::Attack

  # --- App-spezifisch ---
  config.stripe_default_tax_rates = "txr_1M7ePZESnSu3ZRERzwu2VRdq"
  config.imgraetzl_host   = "imgraetzl.at"
  config.welocally_host   = "welocally.at"
  config.platform_admin_email = 'wir@imgraetzl.at'

  # --- Code loading & Caching ---
  config.cache_classes = true
  config.eager_load = true

  # --- Error Reporting ---
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # --- Credentials ---
  # Pflicht, wenn du Rails Credentials verwendest!
  config.require_master_key = true

  # --- Static/Public Files & Assets ---
  # Nutze ENV-Variante, um static files auf dem Server zuzulassen (Heroku-Pattern)
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Asset host für CDN/andere Domains
  config.asset_host = 'https://assets-app.welocally.at'

  # Asset Kompression
  config.assets.js_compressor = :terser
  # config.assets.css_compressor = :sass # nur falls du Sass brauchst

  # Nur vorkompilierte Assets werden genutzt
  config.assets.compile = false

  # Cache-Control Header für Assets (CDN, Browsercaching)
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=31536000',
    'Expires' => 1.year.from_now.to_formatted_s(:rfc822)
  }
  # (Optional: wenn du auch für app/assets eigene Kontrolle willst)
  # config.static_cache_control = 'public, max-age=31536000'

  config.assets.quiet = true

  # --- SSL & Security ---
  config.force_ssl = true

  # --- Logging ---
  config.log_level = ENV.fetch('LOG_LEVEL', 'info').to_sym  # ENV Variable nutzen!
  config.log_tags = [:request_id]
  config.log_formatter = ::Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # --- Caching (alternative: mem_cache_store, redis, etc. je nach Deployment)
  # config.cache_store = :mem_cache_store

  # --- Mailer ---
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
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
  config.x.mandril_from_name = 'imGrätzl.at'
  config.x.mandril_from_email = 'no-reply@imgraetzl.at'

  # --- Internationalisierung ---
  config.i18n.fallbacks = true

  # --- Deprecation & Warnings ---
  config.active_support.deprecation = :notify
  config.active_support.disallowed_deprecation = :log
  config.active_support.disallowed_deprecation_warnings = []

  # --- Schema ---
  config.active_record.dump_schema_after_migration = false

  # --- Active Job ---
  config.active_job.queue_adapter = :delayed_job

  # --- Custom Hosts für DNS Rebinding Schutz, Healthchecks etc. ---
  config.hosts << /.*\.welocally\.at/
  config.hosts << "welocally.at"
  config.hosts << /.*\.imgraetzl\.at/
  config.hosts << "imgraetzl.at"

  # Optional: Healthcheck-Exception
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
