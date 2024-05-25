module CrowdCampaignsHelper

  def runtime_values
    [15, 30, 45, 60].map do |value|
      ["#{value} Tage", value]
    end
  end

  def delivery_week_values
    [
      ["innerhalb 1 Woche", 1],
      ["innerhalb 2 Wochen", 2],
      ["innerhalb 3 Wochen", 3],
      ["innerhalb 1 Monat", 4],
      ["innerhalb 3 Monate", 12],
      ["innerhalb 6 Monate", 24],
      ["innerhalb 9 Monate", 36],
      ["innerhalb 1 Jahr", 48]
    ]
  end

  def delivery_week_names(value)
    case value
    when 1
      "innerhalb 1 Woche"
    when 2
      "innerhalb 2 Wochen"
    when 3
      "innerhalb 3 Wochen"
    when 4
      "innerhalb 1 Monat"
    when 12
      "innerhalb 3 Monate"
    when 24
      "innerhalb 6 Monate"
    when 36
      "innerhalb 9 Monate"
    when 48
      "innerhalb 1 Jahr"
    else
      false
    end
  end

  def percentage_to_value(percentage)
    case percentage
    when 5
      0
    when 6
      1
    when 7
      2
    when 8
      3
    when 9
      4
    when 10
      5
    else
      2
    end
  end

  def billable_values
    [
      ["Nein", 'no_bill'],
      ["Ja, ich kann Rechnungen für Dankeschöns ausstellen", 'bill'],
      ["Ja, ich kann Spendenquittungen ausstellen", 'donation_bill']
    ]
  end

  def available_slots_for(campaign)
    if campaign&.boost_status? && campaign&.crowd_boost_slot_id
      CrowdBoostSlot.where(id: campaign&.crowd_boost_slot_id).map{|g| [g.title, g.id]}
    else
      CrowdBoostSlot.in(current_region).open.map{|g| [g.title, g.id]}
    end
  end

  def campaign_remaining_time(campaign)
    if campaign.remaining_days > 2
      return [campaign.remaining_days, "Tage"]
    end

    end_time = campaign.enddate.in_time_zone('Vienna').end_of_day
    our_time = Time.current.in_time_zone('Vienna')
    hours_left = ((end_time - our_time) / 1.hour).ceil

    [hours_left, 'Stunden']
  end

  def funding_percentage(c)
    # Also show Percentage of Funding_2_Amount
    if c.funding? && c.funding_2?
      c.funding_sum / (c.funding_2_amount / 100)
    else
      c.funding_sum / (c.funding_1_amount / 100)
    end
  end

  def funding_bar_percentage(c)
    if c.completed?
      c.successful? ? 100 : (c.funding_sum / c.funding_1_amount) * 100
    elsif c.funding_1?
      (c.funding_sum / c.funding_1_amount) * 100
    elsif c.over_funding_1?
      percentage = (c.funding_sum - c.funding_1_amount) / c.funding_1_amount * 100
      percentage > 100 ? 85 : percentage
    elsif c.funding_2?
      (c.funding_sum - c.funding_1_amount) / (c.funding_2_amount - c.funding_1_amount) * 100
    elsif c.over_funding_2?
      percentage = (c.funding_sum - c.funding_2_amount) / c.funding_2_amount * 100
      percentage > 100 ? 85 : percentage
    end
  end

  def step_icon(campaign, step)
    if campaign.step_finished?(step)
      icon_tag("check")
    else
      content_tag(:div, "#{step}.", class: 'icon')
    end
  end

  def video_embed_url(url, type)
    @url = url
    @type = type

    youtube_formats = [
      %r(https?://youtu\.be/(.+)),
      %r(https?://www\.youtube\.com/watch\?v=(.*?)(&|#|$)),
      %r(https?://www\.youtube\.com/embed/(.*?)(\?|$)),
      %r(https?://www\.youtube\.com/v/(.*?)(#|\?|$)),
      %r(https?://www\.youtube\.com/user/.*?#\w/\w/\w/\w/(.+)\b),
    ]

    vimeo_formats = [
      %r(https?://vimeo.com\/(\d+)),
      %r(https?:\/\/(www\.)?vimeo.com\/(\d+)),
      %r(https?://player.vimeo.com/video\/(\d+))
    ]

    @url.strip!

    if (@url.include? "youtu") && (@type.include? "url")
      youtube_formats.find { |format| @url =~ format } and $1
      "https://www.youtube.com/embed/#{$1}"
    elsif (@url.include? "vimeo") && (@type.include? "url")
      vimeo_formats.find { |format| @url =~ format } and $1
      "https://player.vimeo.com/video/#{$1}"
    elsif (@url.include? "youtu") && (@type.include? "embed")
      youtube_formats.find { |format| @url =~ format } and $1
      "<youtube-embed>".html_safe +
        "<img loading='lazy' src='https://i.ytimg.com/vi/#{$1}/hqdefault.jpg' alt='Video'>".html_safe +
        "<iframe allow='autoplay' src='' data-src='https://www.youtube.com/embed/#{$1}?autoplay=1' frameborder='0' allow='accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture' allowfullscreen></iframe>".html_safe +
        "<button aria-label='Video abspielen'></button>".html_safe +
      "</youtube-embed>".html_safe
    elsif (@url.include? "vimeo") && (@type.include? "embed")
      vimeo_formats.find { |format| @url =~ format } and $1
      "<vimeo-embed>".html_safe +
        "<img loading='lazy' src='https://vumbnail.com/#{$1}.jpg' alt='Video'>".html_safe +
        "<iframe allow='autoplay' src='' data-src='https://player.vimeo.com/video/#{$1}?autoplay=1' frameborder='0' allow='accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture' allowfullscreen></iframe>".html_safe +
        "<button aria-label='Video abspielen'></button>".html_safe +
      "</vimeo-embed>".html_safe
    end
  end

end
