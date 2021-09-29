class CoopDemandMailer < ApplicationMailer

  def coop_demand_published(coop_demand)
    @coop_demand = coop_demand
    @region = @coop_demand.region

    headers("X-MC-Tags" => "notification-coop-and-share-online")

    mail(
      subject: "Dein Coop & Share Marktplatz Angebot ist online",
      from: platform_email('no-reply'),
      to: @coop_demand.user.email,
    )
  end

end
