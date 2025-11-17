class MarketingMailer < ApplicationMailer

  def contact_list_entry(contact_list_entry)
    @contact_list_entry = contact_list_entry
    @region = contact_list_entry.region || Region.get('wien')

    headers("X-MC-Tags" => "contact-list-entry")

    mail(
      subject: "Interesse am Call zur Aktivierung von Leerstand – Nächste Schritte",
      from: platform_email("wir"),
      to: @contact_list_entry.email,
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

  def supporters_2025(user)
    @user = user
    @region = @user.region

    headers("X-MC-Tags" => "marketing-mail-supporters-2025")

    mail(
      subject: "Danke, dass ihr imGrätzl mittragt, unser Update für euch",
      from: platform_email("mirjam", "Mirjam"),
      to: @user.email,
    )
  end

end
