namespace :scheduled do
  desc 'Expire old zuckerls, publish new ones'
  task daily_zuckerl_publish: :environment do
    Zuckerl.live.where(ends_at: Date.today).find_each do |zuckerl|
      zuckerl.expire!
    end
    Zuckerl.approved.where(starts_at: Date.today).find_each do |zuckerl|
      next if zuckerl.failed? # Dont publish Zuckerls where Payment is failed.
      ZuckerlService.new.publish(zuckerl)
    end
  end
end