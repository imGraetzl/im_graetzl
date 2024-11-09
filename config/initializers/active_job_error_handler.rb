# config/initializers/delayed_job_error_handler.rb

module DelayedJobErrorHandler
  def self.included(base)
    base.around_perform do |job, &block|
      begin
        block.call
      rescue ActiveRecord::RecordNotFound => e
        # Verwaisten Job loggen und überspringen
        Rails.logger.error("Verwaister Job (RecordNotFound) ignoriert: #{e.message}")
        Rails.logger.error("Job ID: #{job.id}, Handler: #{job.handler}, Queue: #{job.queue}")
        job.destroy # Entfernt den Job, um erneute Versuche zu vermeiden
      rescue StandardError => e
        # Allgemeine Fehlerbehandlung
        Rails.logger.error("Fehler im Job #{job.id}: #{e.message}")
        raise e # Wirft den Fehler erneut, um Standard-Fehlerbehandlung zuzulassen
      end
    end
  end
end

Delayed::Worker.plugins << DelayedJobErrorHandler
