module SearchHelper

  def filter_search_types
    [
      ['Allen Bereichen', 'allen Bereichen', ''],
      ['Crowdfunding', 'Crowdfunding', 'crowd_campaigns'],
      ['Raumteiler', 'Raumteiler', 'rooms'],
      ['Events & Workshops', 'Events & Workshops', 'meetings'],
      ['Anbieter & Macherinnen', 'Anbieter & Macherinnen', 'locations'],
      ['Coop & Share', 'Coop & Share', 'coop_demands'],
      ['Gruppen', 'Gruppen', 'groups'],
      ['Umfragen', 'Umfragen', 'polls'],
      ['Energieteiler', 'Energieteiler', 'energies'],
    ]
  end

end
