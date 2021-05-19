module SearchHelper

  def filter_search_types
    [
      ['Allen Bereichen', 'allen Bereichen', ''],
      ['Events & Workshops', 'Events & Workshops', 'meetings'],
      ['Anbieter & Locations', 'Anbieter & Locations', 'locations'],
      ['Raumteiler', 'Raumteiler', 'rooms'],
      ['Toolteiler', 'Toolteiler', 'tool_offers'],
      ['Gruppen', 'Gruppen', 'groups'],
    ]
  end

end
