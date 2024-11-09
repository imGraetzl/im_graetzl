Rails.application.config.active_job.queue_adapter = :delayed_job
Delayed::Worker.delay_jobs = Rails.env.staging? || Rails.env.production?
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.raise_signal_exceptions = false
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.default_priority = 1
Delayed::Worker.queue_attributes = {
  'action-processor' => { priority: 0 },
  'summary-mails' => { priority: 2 }
}

# Plugin-Klasse für Delayed Job
class ErrorHandlerPlugin < Delayed::Plugin
  callbacks do |lifecycle|
    lifecycle.around(:invoke_job) do |job, &block|
      begin
        block.call
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error("Fehler: #{e.message}. Der Job wird abgebrochen.")
      end
    end
  end
end

Delayed::Worker.plugins << ErrorHandlerPlugin