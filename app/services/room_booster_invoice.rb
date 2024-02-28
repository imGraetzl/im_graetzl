class RoomBoosterInvoice

  def invoice(room_booster)
    pdf = Prawn::Document.new
    region = room_booster.region
    add_header(pdf, region)
    add_billing_address(pdf, room_booster)
    add_company_info(pdf, region)
    add_room_booster_info(pdf, room_booster)
    pdf.render
  end

  private

  def add_header(pdf, region)
    pdf.image "#{Rails.root}/app/assets/images/regions/#{region.id}/logo.png", width: 205, position: :right
    pdf.move_down 10
  end

  def add_billing_address(pdf, room_booster)
    pdf.text "Rechnungsempfänger", style: :bold
    pdf.text room_booster.company
    pdf.text room_booster.name
    pdf.text room_booster.address
    pdf.text "#{room_booster.zip} #{room_booster.city}"
    pdf.move_down 40
  end

  def add_company_info(pdf, region)
    pdf.text "Rechnungssteller", style: :bold
    pdf.text "#{I18n.t("region.#{region.id}.domain_full")} wird betrieben von:"
    pdf.text "morgenjungs GmbH"
    pdf.text "Ottakringer Straße 94/11"
    pdf.text "A-1170 Wien"
    pdf.text "UID: ATU 69461502"
    pdf.text "#{I18n.t("region.#{region.id}.contact_email")}"
    pdf.move_down 40
  end

  def add_room_booster_info(pdf, room_booster)
    pdf.text "Rechnungsnummer: #{room_booster.invoice_number}"
    pdf.text "Rechnungsdatum: #{room_booster.created_at.to_date}"
    pdf.move_down 20
    pdf.text "Rechnung", size: 20, style: :bold
    pdf.move_down 20

    table_data = []
    table_data << ["ID ", "Booster für Raumteiler", "Laufzeit", "Sichtbarkeit", "Preis"]
    table_data << [room_booster.id, room_booster.room_offer.to_s.parameterize(preserve_case: true, separator: ' '), room_booster.runtime, room_booster.region.name.to_s, room_booster.basic_price_with_currency]
    table_data << [nil, nil, nil, "(20% MwSt.)", room_booster.tax_with_currency]
    table_data << [nil, nil, nil, "Gesamt", room_booster.total_price_with_currency]

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
