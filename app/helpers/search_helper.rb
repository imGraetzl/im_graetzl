module SearchHelper

  def filter_search_types
    [
      ['Allen Bereichen', 'allen Bereichen', ''],
      ['Crowdfunding', 'Crowdfunding', 'crowd_campaigns'],
      ['Raumteiler', 'Raumteiler', 'rooms'],
      ['Events & Workshops', 'Events & Workshops', 'meetings'],
      ['Anbieter & Macherinnen', 'Anbieter & Macherinnen', 'locations'],
      ['Geräteteiler', 'Geräteteiler', 'tools'],
      ['Coop & Share', 'Coop & Share', 'coop_demands'],
      ['Gruppen', 'Gruppen', 'groups'],
      ['Umfragen', 'Umfragen', 'polls'],
    ]
  end

end
