Rails.application.configure do
  config.enable_reloading = false
  config.cache_classes = true
  config.platform_admin_email = 'michael@imgraetzl.at'

  config.eager_load = ENV["CI"].present?

  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=3600'
  }

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  config.action_dispatch.show_exceptions = false
  config.action_controller.allow_forgery_protection = false

  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: 'test.yourhost.com' }
  config.action_mailer.perform_caching = false

  config.active_support.deprecation = :stderr
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []

  # Optionale, aber empfehlenswerte Defaults:
  # config.i18n.raise_on_missing_translations = true
  # config.action_view.annotate_rendered_view_with_filenames = true
  config.action_controller.raise_on_missing_callback_actions = true

  # Wenn du wirklich für alle URL-Generierungen die Domain setzen willst:
  config.after_initialize do
    Rails.application.routes.default_url_options[:host] = 'www.imgraetzl.at'
  end
end
