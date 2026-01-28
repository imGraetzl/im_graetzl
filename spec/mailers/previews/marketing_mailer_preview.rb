class MarketingMailerPreview < ActionMailer::Preview

  def contact_list_entry
    MarketingMailer.contact_list_entry(ContactListEntry.last)
  end

  def contact_list_entry_sheboost
    MarketingMailer.contact_list_entry_sheboost(ContactListEntry.last)
  end

  def agb_change_and_crowdfunding
    MarketingMailer.agb_change_and_crowdfunding(User.last)
  end

  def supporters_2025
    MarketingMailer.supporters_2025(User.last)
  end

  def crowd_campaign_special
    MarketingMailer.crowd_campaign_special(User.last)
  end

end
