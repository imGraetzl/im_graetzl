# Custom ActiveJob LogSubscriber:
# skips MailDeliveryJob logs to reduce noise in production/staging.

if defined?(ActiveJob::LogSubscriber)

  # Filter out Log Noise
  if Rails.env.production? || Rails.env.staging?
    require "active_job/log_subscriber"

    # Rails-Standard-Subscriber entfernen
    ActiveJob::LogSubscriber.detach_from :active_job

    # Custom Subscriber einhängen
    class CustomActiveJobLogSubscriber < ActiveJob::LogSubscriber
      def enqueue(event)
        job = event.payload[:job]
        return if job.to_s == "ActionMailer::MailDeliveryJob"
        super
      end
    end

    CustomActiveJobLogSubscriber.attach_to :active_job
  end
end