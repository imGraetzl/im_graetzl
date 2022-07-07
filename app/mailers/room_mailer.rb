class RoomMailer < ApplicationMailer

  def room_offer_info_mail(room_offer)
    @room_offer = room_offer
    @region = @room_offer.region

    headers("X-MC-Tags" => "raumteiler-info-mail")

    mail(
      subject: "5 Tipps zu deinem Raumteiler",
      from: platform_email('mirjam', 'Mirjam Mieschendahl'),
      to: @room_offer.user.email,
    )
  end

  def room_demand_info_mail(room_demand)
    @room_demand = room_demand
    @region = @room_demand.region

    headers("X-MC-Tags" => "raumteiler-info-mail")

    mail(
      subject: "4 Tipps zu deinem Raumteiler",
      from: platform_email('mirjam', 'Mirjam Mieschendahl'),
      to: @room_demand.user.email,
    )
  end

  def room_offer_published(room_offer)
    @room_offer = room_offer
    @region = @room_offer.region

    headers("X-MC-Tags" => "notification-room-online")

    mail(
      subject: "Dein Raumteiler ist nun online",
      from: platform_email('no-reply'),
      to: @room_offer.user.email,
    )
  end

  def room_demand_published(room_demand)
    @room_demand = room_demand
    @region = @room_demand.region

    headers("X-MC-Tags" => "notification-room-online")

    mail(
      subject: "Dein Raumteiler ist nun online",
      from: platform_email('no-reply'),
      to: @room_demand.user.email,
    )
  end

  def waiting_list_updated(room_offer, user)
    @room_offer = room_offer
    @user = user
    @region = @room_offer.region

    headers("X-MC-Tags" => "notification-room-waitinglist")

    mail(
      subject: "Neuer User auf deiner Raumteiler Warteliste",
      from: platform_email('no-reply'),
      to: @room_offer.user.email,
    )
  end

  def room_offer_activate_reminder(room_offer)
    @room_offer = room_offer
    @region = @room_offer.region

    headers("X-MC-Tags" => "notification-room-expiring")

    mail(
      subject: "Dein Raumteiler wurde deaktiviert. Möchtest du diesen reaktivieren?",
      from: platform_email('no-reply'),
      to: @room_offer.user.email,
    )
  end

  def room_demand_activate_reminder(room_demand)
    @room_demand = room_demand
    @region = @room_demand.region

    headers("X-MC-Tags" => "notification-room-expiring")

    mail(
      subject: "Dein Raumteiler wurde deaktiviert. Möchtest du diesen reaktivieren?",
      from: platform_email('no-reply'),
      to: @room_demand.user.email,
    )
  end

  def new_rental_request(room_rental)
    @room_rental = room_rental
    @region = @room_rental.region

    headers("X-MC-Tags" => "room-rental-request")

    mail(
      subject: "Neue Raumteiler Buchungsanfrage von #{@room_rental.renter.first_name}",
      from: platform_email('no-reply'),
      to: @room_rental.owner.email,
    )
  end

  def new_rental_request_reminder(room_rental)
    @room_rental = room_rental
    @region = @room_rental.region

    headers("X-MC-Tags" => "room-rental-request-reminder")

    mail(
      subject: "Erinnerung: #{@room_rental.renter.first_name} möchte deinen Raum mieten.",
      from: platform_email('no-reply'),
      to: @room_rental.owner.email,
    )
  end

  def rental_approved_renter(room_rental)
    @room_rental = room_rental
    @region = @room_rental.region

    attachments["#{@room_rental.invoice_number}.pdf"] = @room_rental.renter_invoice.get.body.read
    headers("X-MC-Tags" => "room-rental-approved")

    mail(
      subject: "#{@room_rental.owner.first_name} hat deine Raumteiler Buchung bestätigt",
      from: platform_email('no-reply'),
      to: @room_rental.renter.email,
    )
  end

  def rental_approved_owner(room_rental)
    @room_rental = room_rental
    @region = @room_rental.region

    attachments["#{@room_rental.invoice_number}_owner.pdf"] = @room_rental.owner_invoice.get.body.read
    attachments["#{@room_rental.invoice_number}_renter.pdf"] = @room_rental.renter_invoice.get.body.read
    headers("X-MC-Tags" => "room-rental-approved")

    mail(
      subject: "Bestätigung deiner Raumteiler Vermietung",
      from: platform_email('no-reply'),
      to: @room_rental.owner.email,
    )
  end

  def rental_rejected(room_rental)
    @room_rental = room_rental
    @region = @room_rental.region

    headers("X-MC-Tags" => "room-rental-rejected")

    mail(
      subject: "#{@room_rental.owner.first_name} hat deine Raumteiler Buchungsanfrage abgelehnt.",
      from: platform_email('no-reply'),
      to: @room_rental.renter.email,
    )
  end

  def rental_canceled(room_rental)
    @room_rental = room_rental
    @region = @room_rental.region

    headers("X-MC-Tags" => "room-rental-canceled")

    mail(
      subject: "#{@room_rental.renter.first_name} hat die Raumteiler Buchungsanfrage zurückgezogen",
      from: platform_email('no-reply'),
      to: @room_rental.owner.email,
    )
  end

  def rental_payment_failed(room_rental)
    @room_rental = room_rental
    @region = @room_rental.region

    headers("X-MC-Tags" => "room-rental-payment-failed")

    mail(
      subject: "Probleme bei deiner Zahlung",
      from: platform_email('no-reply'),
      to: @room_rental.owner.email,
    )
  end

end
