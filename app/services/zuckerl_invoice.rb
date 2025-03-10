class ZuckerlInvoice

  def invoice(zuckerl)
    pdf = Prawn::Document.new
    region = zuckerl.region
    add_header(pdf, region)
    add_billing_address(pdf, zuckerl)
    add_company_info(pdf, region)
    add_zuckerl_info(pdf, zuckerl)
    pdf.render
  end

  private

  def add_header(pdf, region)
    pdf.image "#{Rails.root}/app/assets/images/regions/#{region.id}/logo.png", width: 205, position: :right
    pdf.move_down 10
  end

  def add_billing_address(pdf, zuckerl)
    pdf.text "Rechnungsempfänger", style: :bold
    pdf.text zuckerl.company
    pdf.text zuckerl.name
    pdf.text zuckerl.address
    pdf.text "#{zuckerl.zip} #{zuckerl.city}"
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

  def add_zuckerl_info(pdf, zuckerl)
    pdf.text "Rechnungsnummer: #{zuckerl.invoice_number}"
    pdf.text "Rechnungsdatum: #{zuckerl.created_at.to_date}"
    pdf.move_down 20
    pdf.text "Rechnung", size: 20, style: :bold
    pdf.move_down 20

    table_data = []
    table_data << ["ID ", "Zuckerl", "Laufzeit", "Sichtbarkeit", "Preis"]
    table_data << [zuckerl.id, zuckerl.title.truncate(50), zuckerl.runtime, zuckerl.visibility, zuckerl.basic_price_with_currency]
    table_data << [nil, nil, nil, "(20% MwSt.)", zuckerl.tax_with_currency]
    table_data << [nil, nil, nil, "Gesamt", zuckerl.total_price_with_currency]

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
