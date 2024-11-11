# lib/tasks/dyno_scheduler.rake
namespace :dyno do
  desc "Schedule dyno configurations based on time and day"
  task schedule: :environment do
    require 'platform-api'

    # Heroku API-Token und App-Name aus ENV-Variablen
    heroku = PlatformAPI.connect_oauth(ENV['HEROKU_API_TOKEN'])
    APP_NAME = ENV['HEROKU_APP_NAME']

    def scale_dyno(heroku, type, target_size, target_quantity)

      target_size = target_size.downcase
      current_config = heroku.formation.info(APP_NAME, type)
      current_size = current_config['size'].downcase
      current_quantity = current_config['quantity']
      current_time = Time.now.in_time_zone('Vienna')

      Rails.logger.info("[Dyno-Scale]: Current time: #{current_time}")
      Rails.logger.info("[Dyno-Scale]: Current configuration for #{type} dyno: Size=#{current_config['size']}, Quantity=#{current_quantity}")
      Rails.logger.info("[Dyno-Scale]: Target configuration for #{type} dyno: Size=#{target_size.capitalize}, Quantity=#{target_quantity}")

      # Skalierung nur ausführen, wenn die Konfiguration abweicht
      if current_size == target_size && current_quantity == target_quantity
        Rails.logger.info("[Dyno-Scale]: No scaling needed for #{type} dyno. Current configuration matches.")
      else
        Rails.logger.info("[Dyno-Scale]: Scaling needed for #{type} dyno. Proceeding with scale action.")
        begin
          response = heroku.formation.update(APP_NAME, type, { size: target_size.capitalize, quantity: target_quantity })
          Rails.logger.info("[Dyno-Scale]: Scale successful: #{response.inspect}")
        rescue Excon::Error::UnprocessableEntity => e
          Rails.logger.error("[Dyno-Scale]: Error scaling dyno: #{e.message}")
          Rails.logger.error("[Dyno-Scale]: Parameters used: Size=#{target_size.capitalize}, Quantity=#{target_quantity}")
        end
      end
    end

    def schedule_dyno_configurations(heroku)
      current_time = Time.now.in_time_zone('Vienna')
      day_of_week = current_time.strftime('%A')
      hour = current_time.hour

      # Worker-Dynos am Dienstag zwischen 05:00 und 08:00 Uhr auf 2 Dynos setzen und danach wieder auf 1 reduzieren
      if day_of_week == 'Tuesday' && hour >= 5 && hour <= 8
        scale_dyno(heroku, 'worker', 'Standard-2X', 2)
      elsif day_of_week == 'Tuesday' && hour >= 8
        scale_dyno(heroku, 'worker', 'Standard-1X', 1)
      end

      # Nachtkonfiguration für Web Dynos (1 Dyno zwischen 22:00 und 06:00)
      if hour >= 22 || hour <= 6
        scale_dyno(heroku, 'web', 'Standard-2X', 1)
      else
        scale_dyno(heroku, 'web', 'Standard-2X', 2)
      end
    end

    # Scheduler ausführen
    schedule_dyno_configurations(heroku)
  end
end
