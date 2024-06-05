# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer
class AdminMailerPreview < ActionMailer::Preview

  def daily_mail
    AdminMailer.daily_mail
  end

  def new_zuckerl
    AdminMailer.new_zuckerl(Zuckerl.last)
  end

  def new_room_booster
    AdminMailer.new_room_booster(RoomBooster.last)
  end

  def new_crowd_boost_charge
    AdminMailer.new_crowd_boost_charge(CrowdBoostCharge.last)
  end
end
