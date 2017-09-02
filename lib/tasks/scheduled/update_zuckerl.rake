namespace :scheduled do
  desc 'Expire old zuckerls, publish new ones'
  task monthly_zuckerl_publish: :environment do
    if Date.today.day == 1
      puts "Rake monthly_zuckerl_publish start at #{Time.now}"
      last_month = Date.today.last_month
      ZuckerlPublisher.new.expire_published
      ZuckerlPublisher.new.publish_drafted(last_month.beginning_of_month..last_month.end_of_month)
    end
  end
end
