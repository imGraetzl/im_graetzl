module PollsHelper

  def filter_energieteiler_types
    [
      ['Alle Inhalte', 'all'],
      ['Energieteiler', 'poll'],
      ['Expert*innen & Anlaufstellen', 'location'],
      ['Events & Workshops', 'meeting'],
    ]
  end

  def plz_list(poll)
    if current_region.use_districts?
      if poll.energieteiler?
        [poll.zip]
      else
        region_districts_count = District.in(current_region).size
        poll_districts_count = poll.districts.size
        (region_districts_count != poll_districts_count) ? poll.districts.sort_by(&:zip).map(&:zip) : false
      end
    end
  end

  def poll_type_path(poll_type)
    case poll_type
    when 'Energieteiler'
      energieteiler_path
    else
      region_polls_path
    end
  end

end
