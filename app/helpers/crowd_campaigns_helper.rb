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

  def billable_values
    [
      ["Nein", 'no_bill'],
      ["Ja, ich kann Rechnungen für Dankeschöns ausstellen", 'bill'],
      ["Ja, ich kann Spendenquittungen ausstellen", 'donation_bill']
    ]
  end

  def campaign_remaining_time(campaign)
    if campaign.remaining_days > 1
      return [campaign.remaining_days, "Tage"]
    end

    end_time = campaign.enddate.in_time_zone('Vienna').end_of_day
    our_time = Time.current.in_time_zone('Vienna')
    hours_left = ((end_time - our_time) / 1.hour).ceil

    [hours_left, 'Stunden']
  end

  def funding_percentage(c)
    c.funding_sum / (c.funding_1_amount / 100)
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

  def crowd_pledge_login_params
    params.permit(:crowd_campaign_id, :crowd_reward_id, :donation_amount)
  end

  def crowd_donation_login_params
    params.permit(:crowd_campaign_id, :crowd_donation_id)
  end

end
