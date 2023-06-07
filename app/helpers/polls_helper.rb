module PollsHelper

  def plz_list(poll)
    if current_region.use_districts?

      if poll.poll_type == 'Energieteiler'
        [poll.zip]
      else
        region_districts_count = District.in(current_region).size
        poll_districts_count = poll.districts.size
        (region_districts_count != poll_districts_count) ? poll.districts.sort_by(&:zip).map(&:zip) : false
      end
  
    end
  end

end
