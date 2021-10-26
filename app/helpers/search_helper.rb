module SearchHelper

  def filter_search_types
    [
      ['Allen Bereichen', 'allen Bereichen', ''],
      ['Events & Workshops', 'Events & Workshops', 'meetings'],
      ['Anbieter & Macherinnen', 'Anbieter & Macherinnen', 'locations'],
      ['Raumteiler', 'Raumteiler', 'rooms'],
      ['Toolteiler', 'Toolteiler', 'tools'],
      ['Coop & Share', 'Coop & Share', 'coop_demands'],
      ['Gruppen', 'Gruppen', 'groups'],
    ]
  end

end
