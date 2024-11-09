Delayed::Worker.lifecycle.before(:perform) do |job|
  begin
    job.payload_object # Versucht, den Job zu deserialisieren
  rescue ActiveRecord::RecordNotFound => e
    # Ausführliche Informationen über den verwaisten Job ins Log schreiben
    Rails.logger.error("Verwaister Job entdeckt und entfernt:")
    Rails.logger.error("Job ID: #{job.id}")
    Rails.logger.error("Queue: #{job.queue}")
    Rails.logger.error("Handler: #{job.handler}")
    Rails.logger.error("Fehlermeldung: #{e.message}")
    
    job.destroy # Entfernt den verwaisten Job
    nil # Verhindert, dass der Job erneut ausgeführt wird
  end
end