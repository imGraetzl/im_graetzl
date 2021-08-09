module SearchHelper

  def filter_search_types
    [
      ['Allen Bereichen', 'allen Bereichen', ''],
      ['Events & Workshops', 'Events & Workshops', 'meetings'],
      ['Anbieter & Locations', 'Anbieter & Locations', 'locations'],
      ['Raumteiler', 'Raumteiler', 'rooms'],
      ['Toolteiler', 'Toolteiler', 'tool_offers'],
      ['Coop & Share', 'Coop & Share', 'coop_demands'],
      ['Gruppen', 'Gruppen', 'groups'],
    ]
  end

end
