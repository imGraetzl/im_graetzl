class MarketingMailer < ApplicationMailer

  def agb_change_and_welocally(user)
    @user = user
    @region = @user.region

    headers("X-MC-Tags" => "marketing-mail-welocally")

    mail(
      subject: "Wichtige Information: Neue Services & Änderungen der imGrätzl AGB",
      from: platform_email("wir"),
      to: @user.email,
    )
  end

  def agb_change_and_crowdfunding(user)
    @user = user
    @region = @user.region

    headers("X-MC-Tags" => "marketing-mail-crowdfunding")

    mail(
      subject: "Wichtige Änderungen: Crowdfunding kommt -> Änderungen der imGrätzl AGB",
      from: platform_email("wir"),
      to: @user.email,
    )
  end

end
