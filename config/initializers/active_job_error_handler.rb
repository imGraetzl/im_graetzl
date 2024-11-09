# config/initializers/active_job_error_handler.rb

Rails.logger.info("Active Job Error Handler Initializer geladen")

Delayed::Worker.lifecycle.around(:error) do |job, &block|
  begin
    block.call
  rescue Delayed::DeserializationError => e
    Rails.logger.error("Globaler DeserializationError-Handler: #{e.message}. Job wird übersprungen.")
    # Überspringen, um Neustarts zu verhindern.
    nil
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("Globaler RecordNotFound-Handler: #{e.message}. Job wird übersprungen.")
    # Weitere Behandlung hinzufügen falls nötig
    nil
  end
end
