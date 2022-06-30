class CrowdCampaignInvoice

  def invoice(crowd_campaign)
    pdf = Prawn::Document.new
    region = crowd_campaign.region
    add_header(pdf, region)
    add_billing_address(pdf, crowd_campaign)
    add_company_info(pdf, region)
    add_campaign_invoice(pdf, crowd_campaign)
    pdf.render
  end

  private

  def add_header(pdf, region)
    pdf.image "#{Rails.root}/app/assets/images/regions/#{region.id}/logo.png", width: 205, position: :right
    pdf.move_down 10
  end

  def add_billing_address(pdf, crowd_campaign)
    pdf.text "Rechnungsempfänger", style: :bold
    pdf.text crowd_campaign.contact_company
    pdf.text crowd_campaign.contact_name
    pdf.text crowd_campaign.contact_address
    pdf.text "#{crowd_campaign.zip} #{crowd_campaign.city}"
    pdf.move_down 40
  end

  def add_company_info(pdf, region)
    pdf.text "Rechnungssteller", style: :bold
    pdf.text "#{I18n.t("region.#{region.id}.domain_full")} wird betrieben von:"
    pdf.text "morgenjungs GmbH"
    pdf.text "Breitenfeldergasse 14/2A, 1080 Wien"
    pdf.text "UID: ATU 69461502"
    pdf.move_down 40
  end

  def add_campaign_invoice(pdf, crowd_campaign)
    pdf.text "Rechnungsdatum: #{crowd_campaign.enddate + 14.days}"
    pdf.move_down 20
    pdf.text "Rechnung", size: 20, style: :bold
    pdf.move_down 20
  end

  def format_price(amount)
    "#{'%.2f' % amount} €"
  end

end
