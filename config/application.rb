require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ImGraetzl
  class Application < Rails::Application
    config.load_defaults 7.1
    config.exceptions_app = self.routes

    # Optional:
    # config.autoload_lib(ignore: %w(assets tasks))
    # config.eager_load_paths << Rails.root.join("extras")

    config.time_zone = "Europe/Vienna"
    config.active_record.time_zone_aware_types = [:datetime, :time]
    config.i18n.default_locale = :de
    config.generators.system_tests = nil

    # Disable Rails field_with_errors
    ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
      html_tag.html_safe
    end

    # Shrine
    config.upload_server = if ENV["UPLOAD_SERVER"].present?
      ENV["UPLOAD_SERVER"].to_sym
    elsif Rails.env.production? || Rails.env.staging?
      :s3
    else
      :app
    end

    # gzip
    config.middleware.insert_after ActionDispatch::Static, Rack::Deflater

    # Skylight
    if ENV["SKYLIGHT_ENABLED"] == "true"
      config.skylight.environments << Rails.env
      config.skylight.probes << 'delayed_job'
    end
  end
end
