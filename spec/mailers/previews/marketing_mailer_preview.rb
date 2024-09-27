class MarketingMailerPreview < ActionMailer::Preview

  def contact_list_entry
    MarketingMailer.contact_list_entry(ContactListEntry.last)
  end

  def subscription_meeting_invite
    MarketingMailer.subscription_meeting_invite(User.last)
  end

  def hot_august_room_pusher
    MarketingMailer.hot_august_room_pusher(RoomOffer.last)
  end

  def agb_change_and_welocally
    MarketingMailer.agb_change_and_welocally(User.last)
  end

  def agb_change_and_crowdfunding
    MarketingMailer.agb_change_and_crowdfunding(User.last)
  end

end
