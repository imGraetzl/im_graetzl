class RoomRentalInvoice

  def generate_for_renter(room_rental)
    pdf = Prawn::Document.new
    region = room_rental.region
    add_header(pdf, region)
    add_renter_info(pdf, room_rental)
    add_renter_price_info(pdf, room_rental)
    add_company_info(pdf, region)
    pdf.render
  end

  def generate_for_owner(room_rental)
    pdf = Prawn::Document.new
    region = room_rental.region
    add_header(pdf, region)
    add_owner_info(pdf, room_rental.owner, region)
    add_owner_payout_summary(pdf, room_rental)
    add_owner_price_info(pdf, room_rental)
    pdf.render
  end

  private

  def add_header(pdf, region)
    pdf.image "#{Rails.root}/app/assets/images/regions/#{region.id}/logo.png", width: 205, position: :right
  end

  # RENTER INVOICE
  def add_renter_info(pdf, room_rental)
    pdf.text "Rechnungsempfänger", size: 14, style: :bold
    pdf.text room_rental.renter_company if room_rental.renter_company.present?
    pdf.text room_rental.renter_name
    pdf.text room_rental.renter_address
    pdf.text "#{room_rental.renter_zip} #{room_rental.renter_city}"
    pdf.move_down 30
    pdf.text "Rechnungssteller", size: 14, style: :bold
    pdf.text room_rental.owner.billing_address.company if room_rental.owner.billing_address.company.present?
    pdf.text "UID: #{room_rental.owner.billing_address.vat_id}" if room_rental.owner.billing_address.vat_id.present?
    pdf.text "#{room_rental.owner.billing_address.first_name} #{room_rental.owner.billing_address.last_name}"
    pdf.text room_rental.owner.billing_address.street
    pdf.text "#{room_rental.owner.billing_address.zip} #{room_rental.owner.billing_address.city}"
    pdf.move_down 30
  end

  def add_renter_price_info(pdf, room_rental)
    pdf.text "Rechnung", size: 20, style: :bold
    pdf.move_down 10
    pdf.text "Rechnungsnummer: #{room_rental.invoice_number}"
    pdf.text "Transaktionsnummer: #{room_rental.id}"
    pdf.text "Datum: #{room_rental.created_at.to_date}"
    pdf.move_down 20

    table_data = []
    table_data << ["Raumteiler", "Miete", nil, "Preis"]
    table_data << [room_rental.room_offer.slogan, room_rental.rental_period, nil ,format_price(room_rental.basic_price)]
    table_data << [nil, nil, "Rabatt", format_price(-room_rental.discount)] if room_rental.discount?
    table_data << [nil, nil, "20% MwSt.", format_price(room_rental.tax)]
    table_data << [nil, nil, "Gesamt", format_price(room_rental.total_price)]

    pdf.table(table_data, width: pdf.bounds.width, column_widths: {3 => 80}) do
      cells.borders = []
      cells.border_color = "DDDDDD"
      row(0).background_color = "EEEEEE"
      row(0).borders = [:top, :bottom]
      row(1).borders = [:bottom]
      row(-1).borders = [:top]
      row(3).font_style = :bold unless room_rental.discount?
      row(4).font_style = :bold
      column(4).style(:align => :right)
    end
    pdf.move_down 100
  end

  # OWNER INVOICE
  def add_owner_info(pdf, owner, region)
    pdf.text "Rechnungsempfänger", size: 14, style: :bold
    pdf.text owner.billing_address.company if owner.billing_address.company.present?
    pdf.text "UID: #{owner.billing_address.vat_id}" if owner.billing_address.vat_id.present?
    pdf.text owner.billing_address.full_name
    pdf.text owner.billing_address.street
    pdf.text "#{owner.billing_address.zip} #{owner.billing_address.city}"
    pdf.move_down 30
    pdf.text "Rechnungssteller", size: 14, style: :bold
    pdf.text "morgenjungs GmbH / #{I18n.t("region.#{region.id}.domain_full")}"
    pdf.text "Ottakringer Straße 94/11"
    pdf.text "A-1170 Wien"
    pdf.move_down 30
  end

  def add_owner_payout_summary(pdf, room_rental)
    pdf.text "Raumteiler Buchung - Zusammenfassung", size: 14, style: :bold
    pdf.move_down 10

    table_data = []

    table_data << ["Raumteiler Vermietung", nil, nil]
    table_data << ["#{room_rental.room_offer.slogan}\n#{room_rental.rental_period}", "Mietpreis inkl. MwSt.", format_price(room_rental.total_price)]
    table_data << [nil, "abzgl. Servicegebühr inkl. MwSt.", format_price(-room_rental.service_fee)]
    table_data << [nil, "Auszahlungsbetrag", format_price(room_rental.owner_payout_amount)]

    pdf.table(table_data, width: pdf.bounds.width, column_widths: {2 => 80}) do
      cells.borders = []
      cells.border_color = "DDDDDD"
      row(0).background_color = "EEEEEE"
      row(0).borders = [:top, :bottom]
      row(1).borders = [:bottom]
      row(-1).borders = [:top]
      row(3).font_style = :bold
      column(2).style(:align => :right)
    end
    pdf.move_down 30
  end

  def add_owner_price_info(pdf, room_rental)
    pdf.text "Rechnung", size: 20, style: :bold
    pdf.move_down 10
    pdf.text "Rechnungsnummer: #{room_rental.invoice_number}"
    pdf.text "Transaktionsnummer: #{room_rental.id}"
    pdf.text "Datum: #{room_rental.created_at.to_date}"
    pdf.move_down 20

    table_data = []

    table_data << ["Raumteiler", nil]
    table_data << ["#{room_rental.room_offer.slogan}\n#{room_rental.rental_period}\n#{format_price(room_rental.total_price)}", nil]
    table_data << ["Servicegebühr", format_price(room_rental.basic_service_fee)]
    table_data << ["20% MwSt.", format_price(room_rental.service_fee_tax)]
    table_data << ["Servicegebühr Gesamt", format_price(room_rental.service_fee)]

    pdf.table(table_data, width: pdf.bounds.width, column_widths: {1 => 80}) do
      cells.borders = []
      cells.border_color = "DDDDDD"
      row(0).background_color = "EEEEEE"
      row(0).borders = [:top, :bottom]
      row(1).borders = [:bottom]
      row(-1).borders = [:top]
      row(4).font_style = :bold
      column(2).style(:align => :right)
    end
    pdf.move_down 100
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
