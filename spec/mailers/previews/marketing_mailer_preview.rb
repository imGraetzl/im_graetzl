class MarketingMailerPreview < ActionMailer::Preview

  def contact_list_entry
    MarketingMailer.contact_list_entry(ContactListEntry.last)
  end

  def toolteiler_sunset
    MarketingMailer.toolteiler_sunset(RoomOffer.last)
  end

  def subscription_meeting_invite
    MarketingMailer.subscription_meeting_invite(User.last)
  end

  def agb_change_and_welocally
    MarketingMailer.agb_change_and_welocally(User.last)
  end

  def agb_change_and_crowdfunding
    MarketingMailer.agb_change_and_crowdfunding(User.last)
  end

end
