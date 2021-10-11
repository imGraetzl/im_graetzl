module MeetingsHelper

  def filter_meeting_types
    [
      ['Alle Events', 'online & offline Events', ''],
      ['Online Events', 'online Events', 'online'],
      ['Offline Events', 'offline Events', 'offline'],
    ]
  end

  def meeting_past_flag(meeting)
    '-past' if meeting.try(:starts_at_date).try(:past?)
  end

  def meeting_link_text(meeting)
    if meeting.paid?
      'Infos & Tickets'
    else
      meeting.try(:starts_at_date).try(:past?) ? 'Ansehen' : 'Mitmachen'
    end
  end

  def localize_time(time, format)
    if time
      I18n.localize(time, format: format)
    end
  end

  def meeting_place(meeting)
    if meeting.online_meeting?
      online_address(meeting)
    else
      meeting_address(meeting)
    end
  end

  def meeting_name(meeting)
    meeting.active? ? content_tag(:h1, meeting.name) : content_tag(:h2, 'ABGESAGT')
  end

  def going_to_params
    params.permit(
      :meeting_id, :meeting_additional_date_id,
      :company, :full_name, :street, :zip, :city
    )
  end

  private

  def map_link(coords)
    "https://maps.google.com?q=#{coords.y},#{coords.x}"
  end

  def meeting_map(meeting)
    if meeting.address_coordinates.present?
      link_to map_link(meeting.address_coordinates), target: '_blank', class: 'iconMapLink' do
        icon_tag("map-location")
      end
    else
      content_tag(:div, icon_tag("map-location"), class: 'iconMapLink')
    end
  end

  def online_address(meeting)
    content_tag(:div, icon_tag("globe"), class: 'iconMapLink') +
    if meeting.online_description? && meeting.online_url?
      link_to(meeting.online_description, meeting.online_url, target: "blank")
    elsif meeting.online_description?
      content_tag(:strong, meeting.online_description)
    elsif meeting.online_url?
      link_to(meeting.online_url, meeting.online_url, target: "blank")
    else
      content_tag(:strong, 'Online Event')
    end
  end

  def meeting_address(meeting)
    meeting_map(meeting) +
    content_tag(:div, class: 'infotxt address') do
      if meeting.location
        concat link_to(meeting.location.name, [meeting.location.graetzl, meeting.location])
      else
        concat content_tag(:strong, meeting.address_description)
      end
      concat meeting.address_street
      concat tag(:br) if meeting.address_street.present?
      concat "#{meeting.address_zip} #{meeting.address_city}"
    end
  end

end
