class BaseApiMailer
  include Rails.application.routes.url_helpers
  include ActionDispatch::Routing::PolymorphicRoutes
  
  URL_OPTIONS = Rails.application.config.action_mailer.default_url_options

  def self.deliver(*args)
    new(*args).deliver
  end

  def deliver
    raise NotImplementedError, "deliver method not implemented for #{self.class}"
  end
end
