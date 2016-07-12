module MailUtils
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers
    include ActionDispatch::Routing::PolymorphicRoutes
  end

  URL_OPTIONS = Rails.application.config.action_mailer.default_url_options
  FROM_EMAIL = Rails.configuration.x.mandril_from_email
  FROM_NAME = Rails.configuration.x.mandril_from_name
end
