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
      ["Nein - Ich stelle keine Rechnungen aus", 'no_bill'],
      ["Ja - Ich stelle Rechnungen ohne Ust. aus", 'bill'],
      ["Ja - Ich stelle Rechnungen inkl. 20% Ust. aus", 'bill_with_tax']
    ]
  end

  def funding_bar_percentage(c)

    if c.completed_successful?
          100

    elsif c.completed_unsuccessful?
          c.crowd_pledges_sum / (c.funding_1_amount / 100)

    elsif c.funding_1?
          c.crowd_pledges_sum / (c.funding_1_amount / 100)

    elsif c.over_funding_1?
          percentage = (c.crowd_pledges_sum - c.funding_1_amount) / (c.funding_1_amount / 100)
          percentage > 100 ? 85 : percentage

    elsif c.funding_2?
          (c.crowd_pledges_sum - c.funding_1_amount) / ((c.funding_2_amount - c.funding_1_amount) / 100)

    elsif c.over_funding_2?
          percentage = (c.crowd_pledges_sum - c.funding_2_amount) / (c.funding_2_amount / 100)
          percentage > 100 ? 85 : percentage

    end

  end

  def step_icon(campaign, step)
    if step_finished?(campaign, step)
      icon_tag("check")
    else
      content_tag(:div, "#{step}.", class: 'icon')
    end
  end

  def all_steps_finished?(campaign)
    step_finished?(campaign, 1) &&
    step_finished?(campaign, 2) &&
    step_finished?(campaign, 3) &&
    step_finished?(campaign, 4) &&
    step_finished?(campaign, 5)
  end

  def step_finished?(campaign, step)
    case step
    when 1
      ![
        campaign.title,
        campaign.slogan,
        campaign.crowd_category_ids,
        campaign.graetzl_id.to_s
      ].any?{ |f| f.nil? || f.empty? }
    when 2
      ![
        campaign.startdate.to_s,
        campaign.enddate.to_s,
        campaign.description,
        campaign.support_description,
        campaign.about_description
      ].any?{ |f| f.nil? || f.empty? }
    when 3
      ![
        campaign.funding_1_amount.to_s,
        campaign.funding_1_description
      ].any?{ |f| f.nil? || f.empty? }
    when 4
      ![
        campaign.crowd_rewards.first&.title,
        campaign.crowd_rewards.first&.amount.to_s,
        campaign.crowd_rewards.first&.description,
        campaign.crowd_rewards.first&.delivery_weeks.to_s
      ].any?{ |f| f.nil? || f.empty? }
    when 5
      ![
        campaign.cover_photo_data
      ].any?{ |f| f.nil? || f.empty? }
    else
      false
    end
  end

end
