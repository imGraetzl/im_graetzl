module PaymentHelper

  def payment_method_last4(payment_method)
    if payment_method.type == 'card'
      payment_method.card.last4
    elsif payment_method.type == 'sepa_debit'
      payment_method.sepa_debit.last4
    else
      nil
    end
  end

  def payment_wallet(payment_method)
    if payment_method.type == 'card'
      payment_method.card.wallet&.type
    else
      nil
    end
  end

  def payment_method_label(payment_method)
    case payment_method
    when 'card'
      "Kreditkarte"
    when 'sepa_debit'
      "SEPA Lastschrift"
    when 'eps'
      "EPS Überweisung"
    end
  end

end
