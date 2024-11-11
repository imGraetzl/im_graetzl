# lib/tasks/dyno_scheduler.rake
namespace :dyno do
  desc "Schedule dyno configurations based on time and day"
  task schedule: :environment do
    require 'platform-api'

    heroku = PlatformAPI.connect_oauth(ENV['HEROKU_API_TOKEN'])
    APP_NAME = ENV['HEROKU_APP_NAME']

    def scale_dyno(heroku, type, target_size, target_quantity)
      target_size = target_size.capitalize # Anpassung für Konsistenz

      # Aktuelle Konfiguration abrufen
      current_config = heroku.formation.info(APP_NAME, type)
      current_size = current_config['size']
      current_quantity = current_config['quantity']
      current_time = Time.now.in_time_zone('Vienna') # Aktuelle Uhrzeit für das Logging

      Rails.logger.info("Current time: #{current_time}")
      Rails.logger.info("Target time for configuration change: #{target_time}")
      Rails.logger.info("Current configuration for #{type} dyno: Size=#{current_size}, Quantity=#{current_quantity}")
      Rails.logger.info("Target configuration for #{type} dyno: Size=#{target_size}, Quantity=#{target_quantity}")

      # Nur skalieren, wenn die Konfiguration abweicht
      if current_size == target_size && current_quantity == target_quantity
        Rails.logger.info("No scaling needed for #{type} dyno. Current configuration matches.")
      else
        Rails.logger.info("Scaling needed for #{type} dyno. Proceeding with scale action.")
        begin
          response = heroku.formation.update(APP_NAME, type, { size: target_size, quantity: target_quantity })
          Rails.logger.info("Scale successful: #{response.inspect}")
        rescue Excon::Error::UnprocessableEntity => e
          Rails.logger.error("Error scaling dyno: #{e.message}")
          Rails.logger.error("Parameters used: Size=#{target_size}, Quantity=#{target_quantity}")
        end
      end
    end

    def schedule_dyno_configurations(heroku)
      current_time = Time.now.in_time_zone('Vienna')
      day_of_week = current_time.strftime('%A')
      hour = current_time.hour

      # Beispiel: Worker-Dynos am Dienstag
      if day_of_week == 'Tuesday' && hour == 0
        scale_dyno(heroku, 'worker', 'Standard-2x', 2)
      end

      # Web Dynos nachts auf 1 Dyno reduzieren
      if hour >= 23 || hour < 7
        scale_dyno(heroku, 'web', 'Standard-2x', 1)
      else
        scale_dyno(heroku, 'web', 'Standard-2x', 2)
      end
    end

    # Scheduler ausführen
    schedule_dyno_configurations(heroku)
  end
end
