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

  def step_icon(object, step)
    if step_finished?(object, step)
      icon_tag("check")
    else
      content_tag(:div, "#{step}.", class: 'icon')
    end
  end

  def all_steps_finished?(object)
    step_finished?(object, 1) &&
    step_finished?(object, 2) &&
    step_finished?(object, 3) &&
    step_finished?(object, 4) &&
    step_finished?(object, 5)
  end

  def step_finished?(object, step)
    case step
    when 1
      ![
        object.title,
        object.slogan,
        object.crowd_category_ids,
        object.graetzl_id.to_s
      ].any?{ |f| f.nil? || f.empty? }
    when 2
      ![
        object.startdate.to_s,
        object.enddate.to_s,
        object.description,
        object.support_description,
        object.about_description
      ].any?{ |f| f.nil? || f.empty? }
    when 3
      ![
        object.funding_1_amount.to_s,
        object.funding_1_description
      ].any?{ |f| f.nil? || f.empty? }
    when 4
      ![
        object.crowd_rewards.first&.title,
        object.crowd_rewards.first&.amount.to_s,
        object.crowd_rewards.first&.description,
        object.crowd_rewards.first&.delivery_weeks.to_s
      ].any?{ |f| f.nil? || f.empty? }
    when 5
      ![
        object.cover_photo_data
      ].any?{ |f| f.nil? || f.empty? }
    else
      false
    end
  end

end
