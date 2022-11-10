namespace :scheduled do
  desc 'Expire old zuckerls, publish new ones'
  task monthly_zuckerl_publish: :environment do
    if Date.today.day == 1
      puts "Rake monthly_zuckerl_publish start at #{Time.now}"
      last_month = Date.today.last_month

      Zuckerl.live.find_each do |zuckerl|
        zuckerl.expire!
      end

      Zuckerl.approved.where(created_at: last_month.beginning_of_month..last_month.end_of_month).find_each do |zuckerl|
        next if zuckerl.failed? # Dont publish Zuckerls where Payment is failed.
        ZuckerlService.new.publish(zuckerl)
      end

      Zuckerl.pending.where(created_at: last_month.beginning_of_month..last_month.end_of_month).find_each do |zuckerl|
        zuckerl.cancel!
      end

    end
  end
end
