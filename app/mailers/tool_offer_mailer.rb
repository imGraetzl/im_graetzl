class ToolOfferMailer < ApplicationMailer

  def tool_offer_published(tool_offer)
    @tool_offer = tool_offer
    @region = @tool_offer.region

    headers("X-MC-Tags" => "notification-tool-online")

    mail(
      subject: "Dein Toolteiler ist nun online",
      from: platform_email('no-reply'),
      to: @tool_offer.user.email,
    )
  end

  def new_rental_request(tool_rental)
    @tool_rental = tool_rental
    @tool_offer = tool_rental.tool_offer
    @region = @tool_offer.region

    headers("X-MC-Tags" => "tool-rental-request")

    mail(
      subject: "Neue Toolteiler Anfrage",
      from: platform_email('no-reply'),
      to: @tool_rental.owner.email,
    )
  end

  def new_rental_request_reminder(tool_rental)
    @tool_rental = tool_rental
    @tool_offer = tool_rental.tool_offer
    @region = @tool_offer.region

    headers("X-MC-Tags" => "tool-rental-request-reminder")

    mail(
      subject: "Erinnerung: #{@tool_rental.renter.first_name} möchte deinen Toolteiler ausborgen.",
      from: platform_email('no-reply'),
      to: @tool_rental.owner.email,
    )
  end

  def rental_approved(tool_rental)
    @tool_rental = tool_rental
    @region = @tool_rental.region

    attachments["#{@tool_rental.invoice_number}.pdf"] = @tool_rental.renter_invoice.get.body.read
    headers("X-MC-Tags" => "tool-rental-approved")

    mail(
      subject: "Deine Toolteiler Buchung wurde bestätigt",
      from: platform_email('no-reply'),
      to: @tool_rental.renter.email,
    )
  end

  def rental_rejected(tool_rental)
    @tool_rental = tool_rental
    @region = @tool_rental.region

    headers("X-MC-Tags" => "tool-rental-rejected")

    mail(
      subject: "Deine Toolteiler Anfrage wurde leider abgelehnt.",
      from: platform_email('no-reply'),
      to: @tool_rental.renter.email,
    )
  end

  def rental_canceled(tool_rental)
    @tool_rental = tool_rental
    @region = @tool_rental.region

    headers("X-MC-Tags" => "tool-rental-canceled")

    mail(
      subject: "#{@tool_rental.renter.first_name} hat die Toolteiler Anfrage zurückgezogen",
      from: platform_email('no-reply'),
      to: @tool_rental.owner.email,
    )
  end

  def rental_return_pending(tool_rental)
    @tool_rental = tool_rental
    @region = @tool_rental.region

    headers("X-MC-Tags" => "tool-rental-return-pending")

    mail(
      subject: "Bitte bestätige die Rückgabe deines Toolteilers.",
      from: platform_email('no-reply'),
      to: @tool_rental.owner.email,
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
    )
  end
end
