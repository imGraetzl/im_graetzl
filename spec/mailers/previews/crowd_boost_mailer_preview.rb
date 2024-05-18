class CrowdBoostMailerPreview < ActionMailer::Preview

  def crowd_boost_charge_invoice
    CrowdBoostMailer.crowd_boost_charge_invoice(CrowdBoostCharge.last)
  end

end
