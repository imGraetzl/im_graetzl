class MarketingMailerPreview < ActionMailer::Preview

  def agb_change_and_welocally
    MarketingMailer.agb_change_and_welocally(User.last)
  end

end
