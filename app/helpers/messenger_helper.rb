module MessengerHelper

  def thread_other_user(thread)
    (thread.users - [current_user]).first || current_user
  end

  def message_thread_class(thread)
    if thread.room_rental_id
      "active room_rental"
    elsif thread.last_message.nil? && params[:thread_id].to_i != thread.id
      "active empty"
    else
      'active'
    end
  end
end
