# config/initializers/delayed_job_error_handler.rb

require 'delayed/plugin'

class DelayedJobErrorHandler < Delayed::Plugin
  callbacks do |lifecycle|
    lifecycle.around(:perform) do |job, &block|
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
        raise e # Wirft den Fehler erneut, um die Standard-Fehlerbehandlung zuzulassen
      end
    end
  end
end

# Registrieren des Plugins bei DelayedJob
Delayed::Worker.plugins << DelayedJobErrorHandler
