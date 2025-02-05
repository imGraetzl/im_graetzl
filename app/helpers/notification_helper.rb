module NotificationHelper

  def filter_notification_types
    [
      ['Allen Bereichen', 'allen Bereichen', ''],
      ['Anbieter & Macherinnen', 'Anbieter & Macherinnen', '["Location"]'],
      ['Raumteiler', 'Raumteiler', '["RoomOffer", "RoomDemand"]'],
      ['Events & Workshops', 'Events & Workshops', '["Meeting"]'],
      ['Crowdfunding', 'Crowdfunding', '["CrowdCampaign"]'],
      ['Coop & Share', 'Coop & Share', '["CoopDemand"]'],
      ['Geräteteiler', 'Geräteteiler', '["ToolOffer", "ToolDemand"]'],
      ['Energieteiler', 'Energieteiler', '["EnergyOffer", "EnergyDemand"]'],
    ]
  end

end
