class ToolMailer < ApplicationMailer

  def tool_demand_published(tool_demand)
    @tool_demand = tool_demand
    @region = @tool_demand.region

    headers("X-MC-Tags" => "notification-tool-online")

    mail(
      subject: "Deine Gerätesuche ist nun online",
      from: platform_email('no-reply'),
      to: @tool_demand.user.email,
    )
  end

  def tool_offer_published(tool_offer)
    @tool_offer = tool_offer
    @region = @tool_offer.region

    headers("X-MC-Tags" => "notification-tool-online")

    mail(
      subject: "Dein Geräteteiler ist nun online",
      from: platform_email('no-reply'),
      to: @tool_offer.user.email,
    )
  end

  def tool_demand_activate_reminder(tool_demand)
    @tool_demand = tool_demand
    @region = @tool_demand.region

    headers("X-MC-Tags" => "notification-tool-expiring")

    mail(
      subject: "Deine Gerätesuche wurde deaktiviert. Möchtest du diese reaktivieren?",
      from: platform_email('no-reply'),
      to: @tool_demand.user.email,
    )
  end

  def new_rental_request(tool_rental)
    @tool_rental = tool_rental
    @tool_offer = tool_rental.tool_offer
    @region = @tool_offer.region

    headers("X-MC-Tags" => "tool-rental-request")

    mail(
      subject: "Neue Geräteteiler Anfrage",
      from: platform_email('no-reply'),
      to: @tool_rental.owner.email,
      bcc: platform_admin_email('michael@imgraetzl.at'),
    )
  end

  def new_rental_request_reminder(tool_rental)
    @tool_rental = tool_rental
    @tool_offer = tool_rental.tool_offer
    @region = @tool_offer.region

    headers("X-MC-Tags" => "tool-rental-request-reminder")

    mail(
      subject: "Erinnerung: #{@tool_rental.renter.first_name} möchte deinen Geräteteiler ausborgen.",
      from: platform_email('no-reply'),
      to: @tool_rental.owner.email,
      bcc: platform_admin_email('michael@imgraetzl.at'),
    )
  end

  def rental_approved(tool_rental)
    @tool_rental = tool_rental
    @region = @tool_rental.region

    attachments["ToolRental_#{@tool_rental.invoice_number}.pdf"] = @tool_rental.renter_invoice.get.body.read
    headers("X-MC-Tags" => "tool-rental-approved")

    mail(
      subject: "Deine Geräteteiler Buchung wurde bestätigt",
      from: platform_email('no-reply'),
      to: @tool_rental.renter.email,
      bcc: platform_admin_email('michael@imgraetzl.at'),
    )
  end

  def rental_rejected(tool_rental)
    @tool_rental = tool_rental
    @region = @tool_rental.region

    headers("X-MC-Tags" => "tool-rental-rejected")

    mail(
      subject: "Deine Geräteteiler Anfrage wurde leider abgelehnt.",
      from: platform_email('no-reply'),
      to: @tool_rental.renter.email,
      bcc: platform_admin_email('michael@imgraetzl.at'),
    )
  end

  def rental_canceled(tool_rental)
    @tool_rental = tool_rental
    @region = @tool_rental.region

    headers("X-MC-Tags" => "tool-rental-canceled")

    mail(
      subject: "#{@tool_rental.renter.first_name} hat die Geräteteiler Anfrage zurückgezogen",
      from: platform_email('no-reply'),
      to: @tool_rental.owner.email,
      bcc: platform_admin_email('michael@imgraetzl.at'),
    )
  end

  def rental_payment_failed(tool_rental)
    @tool_rental = tool_rental
    @region = @tool_rental.region

    headers("X-MC-Tags" => "tool-rental-payment-failed")

    mail(
      subject: "Probleme bei deiner Geräteteiler Zahlung, bitte überprüfe deine Zahlungsmethode.",
      from: platform_email('no-reply'),
      to: @tool_rental.owner.email,
      bcc: platform_admin_email('michael@imgraetzl.at'),
    )
  end

  def rental_return_pending(tool_rental)
    @tool_rental = tool_rental
    @region = @tool_rental.region

    headers("X-MC-Tags" => "tool-rental-return-pending")

    mail(
      subject: "Bitte bestätige die Rückgabe deines Geräteteilers.",
      from: platform_email('no-reply'),
      to: @tool_rental.owner.email,
      bcc: platform_admin_email('michael@imgraetzl.at'),
    )
  end

  def return_confirmed_renter(tool_rental)
    @tool_rental = tool_rental
    @region = @tool_rental.region

    headers("X-MC-Tags" => "tool-rental-return-confirmed-renter")

    mail(
      subject: "#{@tool_rental.owner.first_name} hat die Rückgabe bestätigt. Bewerte nun den Verleihvorgang.",
      from: platform_email('no-reply'),
      to: @tool_rental.renter.email,
      bcc: platform_admin_email('michael@imgraetzl.at'),
    )
  end

  def return_confirmed_owner(tool_rental)
    @tool_rental = tool_rental
    @region = @tool_rental.region

    attachments["#{@tool_rental.invoice_number}_gutschrift.pdf"] = @tool_rental.owner_invoice.get.body.read
    headers("X-MC-Tags" => "tool-rental-return-confirmed-owner")

    mail(
      subject: "Du hast die Rückgabe bestätigt. Deine Gutschrift.",
      from: platform_email('no-reply'),
      to: @tool_rental.owner.email,
      bcc: platform_admin_email('michael@imgraetzl.at'),
    )
  end
end
