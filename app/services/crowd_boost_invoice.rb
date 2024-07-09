class CrowdBoostInvoice

  def invoice(crowd_boost_charge)
    pdf = Prawn::Document.new
    region = crowd_boost_charge.region
    add_header(pdf, region)
    add_billing_address(pdf, crowd_boost_charge)
    add_company_info(pdf, region)
    add_crowd_boost_charge_info(pdf, crowd_boost_charge)
    pdf.render
  end

  private

  def add_header(pdf, region)
    pdf.image "#{Rails.root}/app/assets/images/regions/#{region.id}/logo.png", width: 205, position: :right
    pdf.move_down 10
  end

  def add_billing_address(pdf, crowd_boost_charge)
    pdf.text "Empfänger", style: :bold
    pdf.text crowd_boost_charge.full_name
    pdf.move_down 40
  end

  def add_company_info(pdf, region)
    pdf.text "Aussteller", style: :bold
    pdf.text "#{I18n.t("region.#{region.id}.domain_full")} wird betrieben von:"
    pdf.text "morgenjungs GmbH"
    pdf.text "Ottakringer Straße 94/11"
    pdf.text "A-1170 Wien"
    pdf.text "UID: ATU 69461502"
    pdf.text "#{I18n.t("region.#{region.id}.contact_email")}"
    pdf.move_down 40
  end

  def add_crowd_boost_charge_info(pdf, crowd_boost_charge)
    pdf.text "Belegnummer: #{crowd_boost_charge.invoice_number}"
    pdf.text "Datum: #{crowd_boost_charge.created_at.to_date}"
    pdf.move_down 20
    pdf.text "Zahlungsbeleg", size: 20, style: :bold
    pdf.move_down 20

    pdf.text "CrowdBoost ID: #{crowd_boost_charge.crowd_boost.id}"

    case crowd_boost_charge.charge_type
    when "general"
      pdf.text "via Direkteinzahlung"
    when "zuckerl"
      pdf.text "via Zuckerl ID: #{crowd_boost_charge&.zuckerl&.id}"
    when "room_booster"
      pdf.text "via Raumteiler Pusher ID: #{crowd_boost_charge&.room_booster&.id}"
    when "crowd_pledge"
      pdf.text "via Crowdfunding Unterstützung ID: #{crowd_boost_charge&.crowd_pledge&.id}"
    when "subscription_invoice"
      pdf.text "via Mitgliedschaft Invoice ID: #{crowd_boost_charge&.subscription_invoice&.id}"
    end

    pdf.move_down 20

    table_data = []
    table_data << ["Zahlungs-ID", "CrowdBoost", "Betrag"]
    table_data << [crowd_boost_charge.id, crowd_boost_charge.crowd_boost.to_s.parameterize(preserve_case: true, separator: ' '), format_price(crowd_boost_charge.amount)]

    pdf.table(table_data, width: pdf.bounds.width, column_widths: {5 => 60}) do
      cells.borders = []
      cells.border_color = "DDDDDD"
      row(0).background_color = "EEEEEE"
      row(0).borders = [:top, :bottom]
      row(1).borders = [:bottom]
      row(-1).borders = [:top]
    end
  end

  def format_price(amount)
    "#{'%.2f' % amount.round(2)} €"
  end

end
