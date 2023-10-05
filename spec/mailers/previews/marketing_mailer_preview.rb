class MarketingMailerPreview < ActionMailer::Preview

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
