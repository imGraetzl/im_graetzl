class LocationMailer < ApplicationMailer

  def location_approved(location)
    @location = location
    @region = @location.region

    headers("X-MC-Tags" => "location-approved")

    mail(
      to: @location.user.email,
      from: platform_email("mirjam", "Mirjam Mieschendahl"),
      subject: "Dein Schaufenster wurde freigeschalten",
    )
  end

  def update_goodie_reminder(location)
    @location = location
    @region = @location.region

    headers("X-MC-Tags" => "location-goodie-reminder")

    mail(
      to: @location.user.email,
      from: platform_email('no-reply'),
      subject: "Ist dein Goodie noch aktuell? '#{@location.goodie.truncate(50)}'")
  end

end
