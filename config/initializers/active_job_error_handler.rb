# config/initializers/active_job_error_handler.rb
Delayed::Worker.lifecycle.around(:error) do |job, &block|
  begin
    block.call
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("Globaler Error-Handler: #{e.message}. Job wird übersprungen.")
    nil # Verhindert erneute Versuche und Crash bei RecordNotFound-Fehlern
  end
end
