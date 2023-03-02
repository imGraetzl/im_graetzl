namespace :scheduled do

  desc 'Daily Room Booster PushUps'
  task room_booster_push_and_expire: :environment do

    # Expire Ending Boosters
    RoomBooster.active.where("DATE(ends_at_date) = ?", Date.yesterday).find_each do |room_booster|
      RoomBoosterService.new.expire(room_booster)
    end

    # PushUp Active RoomBoosters
    RoomBooster.active.find_each do |room_booster|
      RoomBoosterService.new.push_up(room_booster)
    end

    # Start Pending Boosters
    RoomBooster.pending.where("DATE(starts_at_date) = ?", Date.today).find_each do |room_booster|
      RoomBoosterService.new.create(room_booster)
    end

  end

end
