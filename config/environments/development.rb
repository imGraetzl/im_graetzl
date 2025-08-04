require "active_support/core_ext/integer/time"

Rails.application.default_url_options = { port: 3000 }
Rails.application.configure do

  config.middleware.insert_before 0, Rack::Attack

  # Taxrates for Stripe
  config.stripe_default_tax_rates = "txr_1NzlODESnSu3ZRERf9VJorBc"

  # Eigene Entwicklung-Hosts
  config.imgraetzl_host = "local.imgraetzl.at"
  config.welocally_host = "local.welocally.at"
  config.platform_admin_email = 'michael@imgraetzl.at'

  # DNS rebinding attack exception
  config.hosts << config.imgraetzl_host
  config.hosts << ".#{config.welocally_host}"

  # Rails 7.1 Defaults:
  config.enable_reloading = true
  config.server_timing = true
  config.eager_load = false

  # Fehleranzeigen
  config.consider_all_requests_local = true

  # Caching wie gehabt
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # ActionMailer
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :letter_opener

  # --- Active Job ---
  config.active_job.queue_adapter = :async

  # Deprecation und Migration Errors
  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []
  config.active_record.migration_error = :page_load

  # Logs
  config.active_record.verbose_query_logs = true
  config.active_job.verbose_enqueue_logs = true

  # Assets
  config.assets.debug = true
  config.assets.quiet = true

  # Fehler für fehlende Controller-Actions
  config.action_controller.raise_on_missing_callback_actions = true

  # File Watcher
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true           # Popup im Browser
    Bullet.bullet_logger = true   # log/bullet.log
    Bullet.rails_logger = true    # Zeigt es im Rails-Log
  end

end
