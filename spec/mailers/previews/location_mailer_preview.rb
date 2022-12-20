class LocationMailerPreview < ActionMailer::Preview

  def location_approved
    LocationMailer.location_approved(Location.last)
  end

  def update_goodie_reminder
    LocationMailer.update_goodie_reminder(Location.approved.goodie.last)
  end

end
