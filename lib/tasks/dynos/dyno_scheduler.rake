# lib/tasks/dyno_scheduler.rake
namespace :dyno do
  desc "Schedule dyno configurations based on time and day"
  task schedule: :environment do
    require 'platform-api'

    # Heroku API-Token und App-Name aus ENV-Variablen
    heroku = PlatformAPI.connect_oauth(ENV['HEROKU_API_TOKEN'])
    APP_NAME = 'imgraetzl'

    def scale_dyno(heroku, type, target_size, target_quantity)

      target_size = target_size.downcase
      current_config = heroku.formation.info(APP_NAME, type)
      current_size = current_config['size'].downcase
      current_quantity = current_config['quantity']

      Rails.logger.info("[Dyno-Scale]: Current configuration for #{type} dyno: Size=#{current_config['size']}, Quantity=#{current_quantity}")
      Rails.logger.info("[Dyno-Scale]: Target configuration for #{type} dyno: Size=#{target_size}, Quantity=#{target_quantity}")

      # Skalierung nur ausführen, wenn die Konfiguration abweicht
      if current_size == target_size && current_quantity == target_quantity
        Rails.logger.info("[Dyno-Scale]: No scaling needed for #{type} dyno. Current configuration matches.")
      else
        Rails.logger.info("[Dyno-Scale]: Scaling needed for #{type} dyno. Proceeding with scale action.")
        begin
          response = heroku.formation.update(APP_NAME, type, { size: target_size, quantity: target_quantity })
          Rails.logger.info("[Dyno-Scale]: Scale successful: #{response.inspect}")
        rescue Excon::Error::UnprocessableEntity => e
          Rails.logger.error("[Dyno-Scale]: Error scaling dyno: #{e.message}")
          Rails.logger.error("[Dyno-Scale]: Parameters used: Size=#{target_size}, Quantity=#{target_quantity}")
        end
      end
    end

    def schedule_dyno_configurations(heroku)
      current_time = Time.now.in_time_zone('Vienna')
      day_of_week = current_time.strftime('%A')
      hour = current_time.hour

      # Worker-Dynos Dienstag zwischen 05:00 und 07:00 Uhr 2 Dynos
      if day_of_week == 'Tuesday' && hour >= 5 && hour <= 7
        scale_dyno(heroku, 'worker', 'Standard-2X', 2)
      elsif day_of_week == 'Tuesday' && hour >= 8
        scale_dyno(heroku, 'worker', 'Standard-1X', 1)
      end

      # Web-Dynos tagsüber 2 Dynos zwischen 06:00 und 22:00 Uhr (Nachts 1 Dyno)
      if hour >= 6 || hour <= 22
        scale_dyno(heroku, 'web', 'Standard-2X', 2)
      else
        scale_dyno(heroku, 'web', 'Standard-2X', 1)
      end
    end

    # Scheduler ausführen
    schedule_dyno_configurations(heroku)
  end
end
