module ZuckerlsHelper
  def zuckerl_state_for(zuckerl)
    case
    when zuckerl.pending?
      content_tag(:div, 'Warten auf Freischaltung', class: 'state') +
      content_tag(:div, 'Wir schicken dir eine E-Mail, sobald dein Zuckerl freigeschalten wurde.', class: 'txt')
    when zuckerl.failed?
      content_tag(:div, 'Fehler bei deiner Zuckerl Abbuchung!', class: 'state') +
      content_tag(:div, "Bitte überprüfe deine Zahlungsmethode, damit dein Zuckerl zeitgerecht im Zeitraum #{zuckerl_runtime zuckerl} laufen kann.", class: 'txt')
    when zuckerl.approved?
      content_tag(:div, 'Dein Zuckerl wurde freigeschalten!', class: 'state') +
      content_tag(:div, "Dein Zuckerl läuft im Zeitraum #{zuckerl_runtime zuckerl} mit der Sichtbarkeit: #{zuckerl.visibility}", class: 'txt')
    when zuckerl.live?
      content_tag(:div, (icon_tag "signal")) +
      content_tag(:div, 'Dein Zuckerl ist aktiv!', class: 'state') +
      content_tag(:div, "Dein Zuckerl ist gerade online mit der Sichtbarkeit: #{zuckerl.visibility}", class: 'txt')
    when zuckerl.expired?
      content_tag(:div, 'Dein Zuckerl ist abgelaufen', class: 'state') +
      content_tag(:div, "Dein Zuckerl war im Zeitraum #{zuckerl_runtime zuckerl} aktiv.", class: 'txt')
    end
  end

  def zuckerl_runtime(zuckerl)
    "#{I18n.localize zuckerl.starts_at, format: '%d. %b'} – #{I18n.localize zuckerl.ends_at, format: '%d. %b, %Y'}"
  end

  def valid_zuckerl_voucher_for(zuckerl)
    zuckerl.user.valid_zuckerl_voucher_for(zuckerl) || zuckerl.user.subscription&.valid_zuckerl_voucher_for(zuckerl)
  end

  def discount(old_price, new_price)
    (100 - (new_price / old_price * 100)).to_i
  end

end
