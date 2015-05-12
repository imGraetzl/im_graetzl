module MeetingsHelper

  def address_value(meeting)
    if meeting.address.street_name.blank?
      nil
    else
      "#{meeting.address.street_name} #{meeting.address.street_number}"
    end
  end
  
end
