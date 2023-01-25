namespace :scheduled do

  desc 'Daily Room Booster PushUps'
  task room_booster_push_and_expire: :environment do

    # Expire Active RoomBoosters after 7 Days
    RoomBooster.active.where("DATE(created_at) = ?", 7.days.ago).find_each do |room_booster|
      RoomBoosterService.new.expire(room_booster)
    end

    # PushUp Active RoomBoosters
    RoomBooster.active.find_each do |room_booster|
      RoomBoosterService.new.push_up(room_booster)
    end

  end

end
