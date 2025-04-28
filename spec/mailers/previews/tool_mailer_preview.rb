class ToolMailerPreview < ActionMailer::Preview

  def tool_offer_published
    ToolMailer.tool_offer_published(ToolOffer.last)
  end

  def tool_demand_activate_reminder
    ToolMailer.tool_demand_activate_reminder(ToolDemand.last)
  end

  def new_rental_request
    ToolMailer.new_rental_request(ToolRental.last)
  end

  def new_rental_request_reminder
    ToolMailer.new_rental_request_reminder(ToolRental.last)
  end

  def rental_approved
    ToolMailer.rental_approved(ToolRental.approved.last || ToolRental.last)
  end

  def rental_rejected
    ToolMailer.rental_rejected(ToolRental.rejected.last || ToolRental.last)
  end

  def rental_canceled
    ToolMailer.rental_canceled(ToolRental.canceled.last || ToolRental.last)
  end

  def rental_payment_failed
    ToolMailer.rental_payment_failed(ToolRental.failed.last || ToolRental.last)
  end

  def rental_return_pending
    ToolMailer.rental_return_pending(ToolRental.approved.last || ToolRental.last)
  end

  def return_confirmed_renter
    ToolMailer.return_confirmed_renter(ToolRental.approved.last || ToolRental.last)
  end

  def return_confirmed_owner
    ToolMailer.return_confirmed_owner(ToolRental.approved.last || ToolRental.last)
  end

end
