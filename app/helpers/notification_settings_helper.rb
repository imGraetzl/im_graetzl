module NotificationSettingsHelper
  SUMMARY_NOTIFICATION_TYPES = [
    Notifications::NewLocationPost,
    Notifications::NewLocation,
    Notifications::NewMeeting,
    Notifications::NewUserPost,
    Notifications::NewRoomOffer,
    Notifications::NewRoomDemand,
    Notifications::NewRoomCall,
  ]

  def notification_settings_mail_options(notification_type)
    if SUMMARY_NOTIFICATION_TYPES.include?(notification_type)
      [['off', 'Aus'], ['immediate', 'Sofort'], ['daily', 'Täglich'], ['weekly', 'Wöchentlich']]
    else
      [['off', 'Aus'], ['immediate', 'Sofort']]
    end
  end
end
