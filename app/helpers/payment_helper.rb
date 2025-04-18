module PaymentHelper

  # Gibt die letzten 4 Ziffern der Karte oder SEPA-IBAN zurück – sicher gegen nil
  def payment_method_last4(payment_method)
    return nil unless payment_method.respond_to?(:type)

    case payment_method.type
    when 'card'
      payment_method.try(:card)&.last4 || payment_method.dig(:card, :last4)
    when 'sepa_debit'
      payment_method.try(:sepa_debit)&.last4 || payment_method.dig(:sepa_debit, :last4)
    else
      nil
    end
  end

  def payment_wallet(payment_method)
    return nil unless payment_method.respond_to?(:type)
  
    if payment_method.type == 'card'
      payment_method.card&.wallet&.type
    else
      nil
    end
  end

  # Lokalisierte Anzeige des Zahlungsmittels
  def payment_method_label(payment_method_type)
    case payment_method_type
    when 'card'
      "Kreditkarte"
    when 'sepa_debit'
      "SEPA Lastschrift"
    when 'eps'
      "EPS Überweisung"
    when 'sofort'
      "Sofortüberweisung"
    when 'bancontact'
      "Bancontact"
    else
      "Zahlungsmittel"
    end
  end

  def statement_descriptor_prefix(region)
    region.host_id.to_s.upcase.gsub(/[^A-Z0-9* ]/, '')
  end

  def statement_descriptor_label(label)
    label.to_s.upcase.gsub(/[^A-Z0-9* ]/, '')
  end

  def statement_descriptor_for(region, label)
    "#{statement_descriptor_prefix(region)} #{statement_descriptor_label(label)}"[0...22]
  end

end
