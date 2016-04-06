desc 'Update live zuckerl'
task update_zuckerl: :environment do
  puts "Rake update_zuckerl start at #{Time.now}"
  last_month = Date.today.last_month
  Zuckerl.live.find_each{|zuckerl| zuckerl.expire!}
  Zuckerl.where('created_at BETWEEN ? AND ?', last_month.beginning_of_month, last_month.end_of_month).find_each do |zuckerl|
    zuckerl.put_live! if zuckerl.may_put_live?
  end
end
