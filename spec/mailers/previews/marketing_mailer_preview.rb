class MarketingMailerPreview < ActionMailer::Preview

  def contact_list_entry
    MarketingMailer.contact_list_entry(ContactListEntry.last)
  end

  def agb_change_and_crowdfunding
    MarketingMailer.agb_change_and_crowdfunding(User.last)
  end

  def agb_change_and_crowdfunding
    MarketingMailer.agb_change_and_crowdfunding(User.last)
  end

  def crowdfunding_280
    MarketingMailer.crowdfunding_280(User.last)
  end

end
