module FavoriteHelper

  def filter_favorite_types
    [
      ['Allen Bereichen', 'allen Bereichen', ''],
      ['NutzerInnen', 'NutzerInnen', '["user"]'],
      ['Anbieter & Macherinnen', 'Anbieter & Macherinnen', '["locations"]'],
      ['Raumteiler', 'Raumteiler', '["room_offer", "room_demand"]'],
      ['Events & Workshops', 'Events & Workshops', '["meeting"]'],
      ['Crowdfunding', 'Crowdfunding', '["crowd_campaign"]'],
      ['Coop & Share', 'Coop & Share', '["coop_demand"]'],
    ]
  end

end
