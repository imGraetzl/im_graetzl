# lib/tasks/dyno_scheduler.rake
namespace :dyno do
  desc "Schedule dyno configurations based on time and day"
  task schedule: :environment do
    require 'platform-api'

    # Heroku API-Token und App-Name aus ENV-Variablen
    heroku = PlatformAPI.connect_oauth(ENV['HEROKU_API_TOKEN'])
    APP_NAME = ENV['HEROKU_APP_NAME']

    def scale_dyno(heroku, type, size, quantity)
      # Aktuelle Konfiguration abrufen
      current_config = heroku.formation.info(APP_NAME, type)
      current_size = current_config['size']
      current_quantity = current_config['quantity']

      # Nur skalieren, wenn die Konfiguration abweicht
      if current_size == size && current_quantity == quantity
        Rails.logger.info("No scaling needed for #{type} dyno. Current configuration matches: Size=#{size}, Quantity=#{quantity}")
      else
        Rails.logger.info("Attempting to scale #{type} dyno to Size=#{size}, Quantity=#{quantity}")
        begin
          response = heroku.formation.update(APP_NAME, type, { size: size, quantity: quantity })
          Rails.logger.info("Scale successful: #{response.inspect}")
        rescue Excon::Error::UnprocessableEntity => e
          Rails.logger.error("Error scaling dyno: #{e.message}")
          Rails.logger.error("Parameters used: Size=#{size}, Quantity=#{quantity}")
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
        scale_dyno(heroku, 'web', 'Standard-1x', 1)
      else
        scale_dyno(heroku, 'web', 'Standard-1x', 2)
      end
    end

    # Scheduler ausführen
    schedule_dyno_configurations(heroku)
  end
end
