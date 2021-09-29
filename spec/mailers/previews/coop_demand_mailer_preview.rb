class CoopDemandMailerPreview < ActionMailer::Preview

  def coop_demand_published
    CoopDemandMailer.coop_demand_published(CoopDemand.last)
  end

end
