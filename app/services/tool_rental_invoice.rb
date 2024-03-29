class ToolRentalInvoice

  def generate_for_renter(tool_rental)
    pdf = Prawn::Document.new
    region = tool_rental.region
    add_header(pdf, region)
    add_renter_info(pdf, tool_rental)
    add_renter_price_info(pdf, tool_rental)
    add_company_info(pdf, region)
    pdf.render
  end

  def generate_for_owner(tool_rental)
    pdf = Prawn::Document.new
    region = tool_rental.region
    add_header(pdf, region)
    add_owner_info(pdf, tool_rental.tool_offer)
    add_owner_price_info(pdf, tool_rental)
    add_company_info(pdf, region)
    pdf.render
  end

  private

  def add_header(pdf, region)
    pdf.image "#{Rails.root}/app/assets/images/regions/#{region.id}/logo.png", width: 205, position: :right
  end

  def add_renter_info(pdf, tool_rental)
    pdf.text tool_rental.renter_company if tool_rental.renter_company.present?
    pdf.text tool_rental.renter_name
    pdf.text tool_rental.renter_address
    pdf.text "#{tool_rental.renter_zip} #{tool_rental.renter_city}"
    pdf.move_down 50
  end

  def add_renter_price_info(pdf, tool_rental)
    pdf.text "Rechnungsnummer: #{tool_rental.invoice_number}"
    pdf.text "Transaktionsnummer: #{tool_rental.id}"
    pdf.text "Datum: #{tool_rental.created_at.to_date}"
    pdf.move_down 10
    pdf.text "Rechnung", size: 20, style: :bold
    pdf.move_down 10

    table_data = []
    table_data << ["Geräteteiler", "Start", "Ende", "Vermieter", "Preis"]
    table_data << [tool_rental.tool_offer.title, tool_rental.rent_from, tool_rental.rent_to, tool_rental.owner.full_name, format_price(tool_rental.basic_price)]
    table_data << [nil, nil, nil, "Rabatt", format_price(-tool_rental.discount)] if tool_rental.discount?
    table_data << [nil, nil, nil, "Servicegebühr", format_price(tool_rental.service_fee)]
    table_data << [nil, nil, nil, "(20% MwSt.)", format_price(tool_rental.tax)]
    table_data << [nil, nil, nil, "Servicegebühr Gesamt (Inkl. MwSt)", format_price(tool_rental.total_fee)]
    table_data << [nil, nil, nil, "Gesamt", format_price(tool_rental.total_price)]

    pdf.table(table_data, width: pdf.bounds.width, column_widths: {4 => 80}) do
      cells.borders = []
      cells.border_color = "DDDDDD"
      row(0).background_color = "EEEEEE"
      row(0).borders = [:top, :bottom]
      row(1).borders = [:bottom]
      row(-1).borders = [:top]
    end
    pdf.move_down 50
  end

  def add_owner_info(pdf, tool_offer)
    pdf.text tool_offer.full_name
    pdf.text tool_offer.address_street
    pdf.text "#{tool_offer.address_zip} #{tool_offer.address_city}"
    pdf.move_down 50
  end

  def add_owner_price_info(pdf, tool_rental)
    pdf.text "Rechnungsnummer: #{tool_rental.invoice_number}"
    pdf.text "Transaktionsnummer: #{tool_rental.id}"
    pdf.text "Datum: #{tool_rental.created_at.to_date}"
    pdf.move_down 10
    pdf.text "Gutschrift", size: 20, style: :bold
    pdf.move_down 10

    table_data = []
    table_data << ["Geräteteiler", "Start", "Ende", "Mieter", "Preis"]
    table_data << [tool_rental.tool_offer.title, tool_rental.rent_from, tool_rental.rent_to, tool_rental.renter_name, format_price(tool_rental.basic_price)]
    table_data << [nil, nil, nil, "Rabatt", format_price(-tool_rental.discount)] if tool_rental.discount?
    table_data << [nil, nil, nil, "Servicegebühr", format_price(-tool_rental.service_fee)]
    table_data << [nil, nil, nil, "(20% MwSt.)", format_price(-tool_rental.tax)]
    table_data << [nil, nil, nil, "Servicegebühr Gesamt (Inkl. MwSt)", format_price(-tool_rental.service_fee - tool_rental.tax)]
    table_data << [nil, nil, nil, "Auszahlungsbetrag", format_price(tool_rental.owner_payout_amount)]

    pdf.table(table_data, width: pdf.bounds.width, column_widths: {4 => 80}) do
      cells.borders = []
      cells.border_color = "DDDDDD"
      row(0).background_color = "EEEEEE"
      row(0).borders = [:top, :bottom]
      row(1).borders = [:bottom]
      row(-1).borders = [:top]
    end
    pdf.move_down 50
  end

  def add_company_info(pdf, region)
    pdf.text "#{I18n.t("region.#{region.id}.domain_full")} wird betrieben von:"
    pdf.text "morgenjungs GmbH"
    pdf.text "Ottakringer Straße 94/11"
    pdf.text "A-1170 Wien"
    pdf.text "#{I18n.t("region.#{region.id}.contact_email")}"
  end

  def format_price(amount)
    "#{'%.2f' % amount.round(2)} €"
  end

end
