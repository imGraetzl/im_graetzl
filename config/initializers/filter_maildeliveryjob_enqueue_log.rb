if Rails.env.production? || Rails.env.staging? || Rails.env.development?
  require "active_job/log_subscriber"

  # Rails-Standard-Subscriber entfernen
  ActiveJob::LogSubscriber.detach_from :active_job

  # Custom Subscriber einhängen
  class CustomActiveJobLogSubscriber < ActiveJob::LogSubscriber
    def enqueue(event)
      return if event.payload[:job] == "ActionMailer::MailDeliveryJob"
      super
    end
  end

  CustomActiveJobLogSubscriber.attach_to :active_job
end
