class CrowdCampaignInvoice

  def invoice(campaign)
    pdf = Prawn::Document.new
    region = campaign.region
    add_header(pdf, region)
    add_billing_address(pdf, campaign)
    add_company_info(pdf, region)
    add_campaign_stats(pdf, campaign)
    add_campaign_invoice(pdf, campaign)
    add_campaign_payout(pdf, campaign)
    pdf.render
  end

  private

  def add_header(pdf, region)
    pdf.image "#{Rails.root}/app/assets/images/regions/#{region.id}/logo.png", width: 200, position: :right
    pdf.move_down 5
  end

  def add_billing_address(pdf, campaign)
    pdf.text campaign.contact_company
    pdf.text campaign.contact_name
    pdf.text campaign.contact_address
    pdf.text "#{campaign.address_zip} #{campaign.address_city}"
    pdf.move_down 30
  end

  def add_company_info(pdf, region)
    pdf.text "Betreff: Deine erfolgreiche Crowdfunding Kampagne auf #{I18n.t("region.#{region.id}.domain_full")}", style: :bold
    pdf.text "morgenjungs GmbH"
    pdf.text "Lassallestraße 13/38, A-1020 Wien"
    pdf.text "UID: ATU 69461502"
    pdf.move_down 20
  end

  def add_campaign_stats(pdf, campaign)
    pdf.text "Rechnungsnummer: #{campaign.invoice_number}"
    pdf.text "Rechnungsdatum: #{Date.today.strftime('%d.%m.%Y')}"
    pdf.text "Kampagne: '#{campaign.title}'"
    pdf.move_down 20
    pdf.text "Wir freuen uns, dir dein erfolgreiches Crowdfunding Projekt auf #{I18n.t("region.#{campaign.region.id}.domain_full")} und die Auszahlung deines Geldes zu bestätigen. Du hast insgesamt #{campaign.funding_count} Unterstützungen für dein Projekt erhalten, herzliche Gratulation! Die Auszahlungssumme (siehe unterhalb) wird dir in den nächsten Tagen auf dein verknüpftes Konto überwiesen. Im Abschnitt 'Rechnung', findest du die Rechnung über die angefallene Servicegebühr."
    pdf.move_down 30

    pdf.text "Fundingstatistik", size: 16, style: :bold
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    pdf.float { pdf.text "Festgelegtes Fundingziel", align: :left }
    pdf.text "#{format_price(campaign.funding_1_amount)}", align: :right
    pdf.float { pdf.text "Festgelegter Optimalbetrag", align: :left } if campaign.funding_2_amount?
    pdf.text "#{format_price(campaign.funding_2_amount)}", align: :right if campaign.funding_2_amount?
    pdf.move_down 10

    pdf.float { pdf.text "Erreichte Fundingsumme", align: :left, style: :bold }
    pdf.text "#{format_price(campaign.funding_sum)}", align: :right, style: :bold
    pdf.float { pdf.text "Davon fehlgeschlagene Transaktionen (#{campaign.crowd_pledges.failed.count})", align: :left }
    pdf.text "- #{format_price(campaign.crowd_pledges_failed_sum)}", align: :right
    pdf.move_down 10

    pdf.float { pdf.text "Tatsächlich erreichte Fundingsumme", align: :left, style: :bold }
    pdf.text "#{format_price(campaign.effective_funding_sum)}", align: :right, style: :bold
    pdf.move_down 25

  end

  def add_campaign_invoice(pdf, campaign)
    pdf.text "Rechnung", size: 16, style: :bold
    pdf.stroke_horizontal_rule
    pdf.move_down 10

    pdf.float { pdf.text "Servicegebühr (Netto)", align: :left }
    pdf.text "#{format_price(campaign.crowd_pledges_fee_netto)}", align: :right
    pdf.float { pdf.text "20% MwSt.", align: :left }
    pdf.text "#{format_price(campaign.crowd_pledges_fee_tax)}", align: :right
    pdf.float { pdf.text "Servicegebühr Gesamt (#{campaign.transaction_fee_percentage}%)", align: :left, style: :bold }
    pdf.text "#{format_price(campaign.crowd_pledges_fee)}", align: :right, style: :bold
    pdf.move_down 25

  end

  def add_campaign_payout(pdf, campaign)
    pdf.text "Auszahlung", size: 16, style: :bold
    pdf.stroke_horizontal_rule
    pdf.move_down 10
    pdf.float { pdf.text "Auszahlungssumme", align: :left, style: :bold }
    pdf.text "#{format_price(campaign.crowd_pledges_payout)}", align: :right, style: :bold
  end

  def format_price(amount)
    "#{'%.2f' % amount.round(2)} €"
  end

end
