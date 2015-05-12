module MeetingsHelper

  def address_value(meeting)
    if meeting.address.street_name.blank?
      nil
    else
      "#{meeting.address.street_name} #{meeting.address.street_number}"
    end
  end

  def current_going_to
    @meeting.going_tos.find_by_user_id(current_user)
  end
  
end
