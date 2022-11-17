module ZuckerlsHelper
  def zuckerl_state_for(zuckerl)
    case
    when zuckerl.pending?
      content_tag(:div, 'Warten auf Freischaltung', class: 'state') +
      content_tag(:div, 'Wir schicken dir eine E-Mail, sobald dein Zuckerl freigeschalten wurde.', class: 'txt')
    when zuckerl.failed?
      content_tag(:div, 'Fehler bei deiner Zuckerl Abbuchung!', class: 'state') +
      content_tag(:div, "Bitte überprüfe deine Zahlungsmethode, damit dein Zuckerl zeitgerecht im #{zuckerl_month_and_year zuckerl} laufen kann.", class: 'txt')
    when zuckerl.approved?
      content_tag(:div, 'Dein Zuckerl wurde freigeschalten!', class: 'state') +
      content_tag(:div, "Dein Zuckerl läuft im #{zuckerl_month_and_year zuckerl} mit der Sichtbarkeit: #{zuckerl.visibility}", class: 'txt')
    when zuckerl.live?
      content_tag(:div, (icon_tag "signal")) +
      content_tag(:div, 'Dein Zuckerl ist aktiv!', class: 'state') +
      content_tag(:div, "Dein Zuckerl ist gerade online mit der Sichtbarkeit: #{zuckerl.visibility}", class: 'txt')
    when zuckerl.expired?
      content_tag(:div, 'Dein Zuckerl ist abgelaufen', class: 'state') +
      content_tag(:div, "Dein Zuckerl war im Monat #{zuckerl_month_and_year zuckerl} aktiv.", class: 'txt')
    end
  end

  def zuckerl_month(zuckerl)
    time = zuckerl.created_at || Time.now
    I18n.localize time.end_of_month+1.day, format: '%B'
  end

  def zuckerl_month_and_year(zuckerl)
    time = zuckerl.created_at || Time.now
    I18n.localize time.end_of_month+1.day, format: '%B %Y'
  end

  def valid_zuckerl_voucher_for(zuckerl)
    zuckerl.user.valid_zuckerl_voucher_for(zuckerl) || zuckerl.user.subscription&.valid_zuckerl_voucher_for(zuckerl)
  end

end
