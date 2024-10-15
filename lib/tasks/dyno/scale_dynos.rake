namespace :dyno do
  desc "Scale Worker-Dynos / Only Tuesday"
  task :auto_scale => :environment do
    app_name = ENV['HEROKU_APP_NAME'] || 'imgraetzl'
    vertical_size = 'standard-2x'
    horizontal_count = 2

    if Date.today.tuesday?
      system("heroku ps:type worker=#{vertical_size} --app #{app_name}")
      system("heroku ps:scale worker=#{horizontal_count} --app #{app_name}")

      puts "Worker-Dynos wurden erfolgreich auf #{horizontal_count} Dynos und #{vertical_size} Größe skaliert."
    end
  end

  desc "Reduce Worker-Dynos / Only Tuesday"
  task :auto_reduce => :environment do
    app_name = ENV['HEROKU_APP_NAME'] || 'imgraetzl'
    vertical_size = 'standard-1x'
    horizontal_count = 1

    if Date.today.tuesday?
      system("heroku ps:type worker=#{vertical_size} --app #{app_name}")
      system("heroku ps:scale worker=#{horizontal_count} --app #{app_name}")

      puts "Worker-Dynos wurden erfolgreich auf #{horizontal_count} Dynos und #{vertical_size} Größe reduziert."
    end
  end
end