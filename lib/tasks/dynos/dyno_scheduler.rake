# lib/tasks/dyno_scheduler.rake
namespace :dyno do
  desc "Schedule dyno configurations based on time and day"
  task schedule: :environment do
    require 'platform-api'

    heroku = PlatformAPI.connect_oauth(ENV['HEROKU_API_TOKEN'])
    APP_NAME = 'imgraetzl-staging' # Dein App-Name

    def log_current_config(heroku, type)
      current_config = heroku.formation.info(APP_NAME, type)
      Rails.logger.info "[#{Time.now}] Current configuration for #{type} dyno: Size=#{current_config['size']}, Quantity=#{current_config['quantity']}"
    end

    def scale_dyno(heroku, type, size, quantity)
      current_config = heroku.formation.info(APP_NAME, type)
      log_current_config(heroku, type)
      # Prüfen, ob eine Änderung notwendig ist
      if current_config['size'] != size || current_config['quantity'] != quantity
        heroku.formation.update(APP_NAME, type, { size: size, quantity: quantity })
        Rails.logger.info "[#{Time.now}] Dyno scaled: Type=#{type}, Size=#{size}, Quantity=#{quantity}"
      else
        Rails.logger.info "[#{Time.now}] No scaling needed for #{type} dyno. Already at desired configuration."
      end
    end

    def schedule_dyno_configurations(heroku)
      current_time = Time.now.in_time_zone('Vienna')
      day_of_week = current_time.strftime('%A')
      hour = current_time.hour

      # Worker-Dynos am Dienstag
      if day_of_week == 'Tuesday' && hour == 0
        scale_dyno(heroku, 'worker', 'Standard-2x', 2)
      end

      # Web Dynos nachts auf 1 Dyno reduzieren
      if hour >= 22 || hour < 6
        scale_dyno(heroku, 'web', 'Standard-1x', 1)
      else
        scale_dyno(heroku, 'web', 'Standard-1x', 2)
      end
    end

    # Scheduler ausführen
    schedule_dyno_configurations(heroku)
  end
end
