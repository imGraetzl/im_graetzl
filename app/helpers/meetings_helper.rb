module MeetingsHelper
  def meeting_past_flag(meeting)
    '-past' if meeting.try(:starts_at_date).try(:past?)
  end

  def meeting_link_text(meeting)
    meeting.try(:starts_at_date).try(:past?) ? 'Ansehen' : 'Mitmachen'
  end

  def address_value(address)
    if address.street_name.blank?
      nil
    else
      "#{address.street_name} #{address.street_number}"
    end
  end

  def localize_time(time, format)
    if time
      I18n.localize(time, format: format)
    else
      '???'
    end
  end

  def address_description(address)
    if address.description.present?
      content_tag(:strong, address.description) + tag(:br)
    elsif address.coordinates.blank?
      content_tag(:strong, 'Ort steht noch nicht fest...')
    end
  end

  def disable_fields
    disable_fields ||= false
  end

  def meeting_location(meeting)
    concat meeting_map(meeting)
    concat meeting_address(meeting)
  end

  def meeting_initiator(meeting)
    if initiator = meeting.responsible_user_or_location
      content_tag(:div, class: 'userPortraitName') do
        concat avatar_for(initiator, 100)
        concat "Erstellt von "
        concat link_to(initiator.try(:username) || initiator.name, '#')
      end
    end
  end

  private

  def meeting_map_icon
    content_tag(:svg,
      content_tag(:use, nil, { 'xlink:href' => '#icon-map-location' }),
      class: 'icon-map-location')
  end

  def map_link(coords)
    "http://www.openstreetmap.org/?mlat=#{coords.y}&mlon=#{coords.x}&zoom=18"
  end

  def meeting_map(meeting)
    if coords = meeting.try(:address).try(:coordinates)
      link_to map_link(coords), target: '_blank', class: 'iconMapLink' do
        meeting_map_icon + 'Karte'
      end
    else
      content_tag(:div, meeting_map_icon, class: 'iconMapLink')
    end
  end

  def meeting_address(meeting)
    content_tag(:div, class: 'address') do
      concat address_description(meeting.address)
      concat "#{meeting.address.street_name} #{meeting.address.street_number}"
      concat tag(:br)
      concat "#{meeting.address.zip} #{meeting.address.city}"
    end
  end
end
