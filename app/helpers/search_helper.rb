module SearchHelper

  def filter_search_types
    [
      ['Allen Bereichen', 'allen Bereichen', ''],
      ['Events & Workshops', 'Events & Workshops', 'meetings'],
      ['Anbieter & Macherinnen', 'Anbieter & Macherinnen', 'locations'],
      ['Raumteiler', 'Raumteiler', 'rooms'],
      ['Geräteteiler', 'Geräteteiler', 'tools'],
      ['Coop & Share', 'Coop & Share', 'coop_demands'],
      ['Gruppen', 'Gruppen', 'groups'],
      ['Crowdfunding', 'Crowdfunding', 'crowd_campaigns'],
    ]
  end

end
