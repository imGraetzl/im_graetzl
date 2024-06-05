class CrowdBoostMailer < ApplicationMailer

  def crowd_boost_charge_invoice(crowd_boost_charge)
    @crowd_boost_charge = crowd_boost_charge
    @crowd_boost = @crowd_boost_charge.crowd_boost
    @region = @crowd_boost_charge.region

    attachments["#{@crowd_boost_charge.invoice_number}.pdf"] = @crowd_boost_charge.invoice.get.body.read
    headers("X-MC-Tags" => "crowd-boost-charge-invoice")

    mail(
      subject: "Dein CrowdBoostCharge",
      from: platform_email('no-reply'),
      to: @crowd_boost_charge.email,
    )
  end

end
