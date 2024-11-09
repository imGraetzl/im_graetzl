# Error-Handling während der Deserialisierung:
# Erweiterung der Delayed::PsychExt-Klasse, die für die Deserialisierung von Jobs zuständig ist.
# Bei ActiveRecord::RecordNotFound, wird er geloggt, und der Job wird verworfen (nil zurückgegeben).

require 'delayed/psych_ext'
Rails.logger.info("Active Job Error Handler Initializer geladen")

module Delayed
  module PsychExt
    def visit_Psych_Nodes_Mapping(object)
      super
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error("Fehler bei Delayed Job Deserialisierung: #{e.message}. Job wird übersprungen.")
      nil # Gibt `nil` zurück, um den Job als fehlgeschlagen zu markieren und nicht erneut auszuführen
    end
  end
end
