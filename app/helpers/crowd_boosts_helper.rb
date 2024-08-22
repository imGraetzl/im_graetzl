module CrowdBoostsHelper

  def charge_type(crowd_boost_charge)
    case crowd_boost_charge.charge_type
    when "general"
      link_to "Direkteinzahlung", new_crowd_boost_crowd_boost_charge_path(crowd_boost_charge.crowd_boost), class: 'via-link'
    when "zuckerl"
      link_to "Zuckerl", zuckerls_user_path, class: 'via-link'
    when "room_booster"
      link_to "Raumteiler Pusher", room_boosters_user_path, class: 'via-link'
    when "crowd_pledge"
      link_to "Crowdfunding Unterstützung", new_crowd_boost_crowd_boost_charge_path(crowd_boost_charge.crowd_boost), class: 'via-link'
    when "subscription_invoice"
      link_to "Mitgliedschaft", subscription_plans_path, class: 'via-link'
    when "good_morning_date"
      link_to "Good Morning Date", '/good-morning-dates', class: 'via-link'
    else
      link_to "Direkteinzahlung", new_crowd_boost_crowd_boost_charge_path(crowd_boost_charge.crowd_boost), class: 'via-link'
    end
  end

end
