# lib/tasks/tool_cleanup.rake
namespace :cleanup do
  desc "Entfernt alle Tool-Datenmodelle inklusive Bilder via .destroy. Mit DRY_RUN=true nur Simulation."
  task remove_tool_data: :environment do
    logger = Rails.logger

    dry_run = ENV["DRY_RUN"] == "true"
    logger.info "🚧 Starte Tool-Datenbereinigung#{' im DRY-RUN-Modus' if dry_run}"

    models = {
      ToolRental => "ToolRental",
      ToolOffer => "ToolOffer",
      ToolDemand => "ToolDemand",
      ToolDemandGraetzl => "ToolDemandGraetzl",
      ToolCategory => "ToolCategory"
    }

    models.each do |model, name|
      if model.table_exists?
        total = model.count
        logger.info "🔧 Finde #{total} Einträge in #{name}..."

        model.find_each(batch_size: 100) do |record|
          logger.debug "#{'(DRY-RUN) ' if dry_run}→ #{name} ##{record.id} #{dry_run ? 'würde gelöscht werden' : 'wird gelöscht'}"
          record.destroy unless dry_run
        rescue => e
          logger.error "⚠️ Fehler bei #{name} ##{record.id}: #{e.class} – #{e.message}"
        end

        logger.info "✅ Durchlauf für #{name} abgeschlossen."
      else
        logger.warn "❌ Tabelle für #{name} existiert nicht (vermutlich bereits entfernt)."
      end
    end

    logger.info "🎉 Tool-Datenbereinigung abgeschlossen#{' (nur simuliert)' if dry_run}."
  end
end
