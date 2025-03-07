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

  def address_short_for(record)
    case record
    when Location
      return unless record.using_address?
      address_zip = record.address_zip
      address_street = record.address_street
      address_city = record.address_city
    when User
      address_zip = record.address_zip
      address_street = record.graetzl
      address_city = record.graetzl
    else
      return ""
    end
    use_districts = record.respond_to?(:region) && record.region&.use_districts?
    use_districts ? "#{address_zip}, #{address_street}" : "#{address_street || address_city}"
  end
  
  def graetzl_select_options_zuckerl(zuckerl)

    price = Zuckerl.price(current_region)
    old_price = Zuckerl.old_price(current_region)
    region_price = Zuckerl.region_price(current_region)
    region_old_price = Zuckerl.region_old_price(current_region)

    sorted_graetzls = current_region.graetzls.sort_by(&:zip_name)

    # ---------------- Zuckerl Create
    if zuckerl.new_record?
      return sorted_graetzls.map { |g| [g.name, g.id, { 'data-label' => "#{t("region.#{current_region.id}.in_graetzl")} #{g.name}", 'data-price' => price, 'data-old-price' => old_price }] }
                             .unshift(["Ganz #{current_region.name}", "entire_region", { 'data-label' => "in ganz #{current_region.name}", 'data-price' => region_price, 'data-old-price' => region_old_price }])
    end
  
    # ---------------- Zuckerl Edit
    options = sorted_graetzls.map do |g|
      [
        g.name,
        g.id,
        {
          'data-label' => "#{t("region.#{current_region.id}.in_graetzl")} #{g.name}",
          'data-price' => price,
          'data-old-price' => old_price,
          disabled: zuckerl.entire_region?
        }
      ]
    end
  
    entire_region_option = [
      "Ganz #{current_region.name}",
      "entire_region",
      {
        'data-label' => "in ganz #{current_region.name}",
        'data-price' => region_price,
        'data-old-price' => region_old_price,
        disabled: !zuckerl.entire_region?
      }
    ]
  
    options.unshift(entire_region_option)

  end

  def district_select_options_zuckerl(zuckerl)

    price = Zuckerl.price(current_region)
    old_price = Zuckerl.old_price(current_region)
    region_price = Zuckerl.region_price(current_region)
    region_old_price = Zuckerl.region_old_price(current_region)
  
    sorted_districts = current_region.districts.sort_by(&:zip)
  
    # ---------------- Zuckerl Create
    if zuckerl.new_record?
      return sorted_districts.map { |d| [d.zip_name, d.id, { 'data-label' => "im gesamten #{d.numeric}. Bezirk", 'data-price' => price, 'data-old-price' => old_price }] }
                             .unshift(["Ganz #{current_region.name}", "entire_region", { 'data-label' => "in ganz #{current_region.name}", 'data-price' => region_price, 'data-old-price' => region_old_price }])
    end
  
    # ---------------- Zuckerl Edit
    options = sorted_districts.map do |d|
      [
        d.zip_name,
        d.id,
        {
          'data-label' => "im gesamten #{d.numeric}. Bezirk",
          'data-price' => price,
          'data-old-price' => old_price,
          disabled: zuckerl.entire_region?
        }
      ]
    end
  
    entire_region_option = [
      "Ganz #{current_region.name}",
      "entire_region",
      {
        'data-label' => "in ganz #{current_region.name}",
        'data-price' => region_price,
        'data-old-price' => region_old_price,
        disabled: !zuckerl.entire_region?
      }
    ]
  
    options.unshift(entire_region_option)
  end
  

end
