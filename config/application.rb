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
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.exceptions_app = self.routes

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Europe/Vienna"
    # config.eager_load_paths << Rails.root.join("extras")

    config.active_record.time_zone_aware_types = [:datetime, :time]
    config.i18n.default_locale = :de

    # Disable Rails field_with_errors
    ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
      html_tag.html_safe
    end

    # Configure shrine upload location
    config.upload_server = if ENV["UPLOAD_SERVER"].present?
      ENV["UPLOAD_SERVER"].to_sym
    elsif Rails.env.production? || Rails.env.staging?
      :s3
    else
      :app
    end

    # gzip compression
    config.middleware.insert_after ActionDispatch::Static, Rack::Deflater

    # skylight gem config -> needed if skylight gem is used:
    config.skylight.environments << "staging"
    config.skylight.probes << 'delayed_job'

  end
end
