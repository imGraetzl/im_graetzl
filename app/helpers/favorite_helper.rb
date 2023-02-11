module FavoriteHelper

  def filter_favorite_types
    [
      ['Allen Bereichen', 'allen Bereichen', ''],
      ['NutzerInnen', 'NutzerInnen', '["user"]'],
      ['Anbieter & Macherinnen', 'Anbieter & Macherinnen', '["locations"]'],
      ['Raumteiler', 'Raumteiler', '["room_offer", "room_demand"]'],
      ['Events & Workshops', 'Events & Workshops', '["meeting"]'],
      ['Coop & Share', 'Coop & Share', '["coop_demand"]'],
      ['Crowdfunding', 'Crowdfunding', '["crowd_campaign"]'],
      ['Geräteteiler', 'Geräteteiler', '["tool_offer", "tool_demand"]'],
      ['Zuckerl', 'Zuckerl', '["zuckerl"]'],
    ]
  end

end
