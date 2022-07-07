class WebhooksController < ApplicationController
  skip_forgery_protection

  def stripe
    head :bad_request and return if params[:type].blank? || params[:id].blank?

    event = Stripe::Event.retrieve(params[:id])
    case event.type
    when "payment_intent.succeeded"
      payment_intent_succeded(event.data.object)
    when "payment_intent.payment_failed"
      payment_intent_failed(event.data.object)
    end

    head :ok
  end

  def mailchimp
    if request.get?
      render plain: 'Hello, Mailchimp!' # Verify Webhook Address
    elsif request.post? && params[:type].present? && params[:data].present?
      type, data = params['type'], params['data']
      if type == 'unsubscribe'
        user = User.find_by_email(data['email'])
        user.update(newsletter: false) if !user.nil?
      end
    end
  end

  private

  def payment_intent_succeded(payment_intent)

    if payment_intent.metadata["pledge_id"]
      crowd_pledge = CrowdPledge.find_by(id: payment_intent.metadata.pledge_id)
      if crowd_pledge
        CrowdPledgeService.new.payment_succeeded(crowd_pledge, payment_intent)
      end
    end

    if payment_intent.metadata["room_rental_id"]
      room_rental = RoomRental.find_by(id: payment_intent.metadata.room_rental_id)
      RoomRentalService.new.payment_succeeded(room_rental, payment_intent) if room_rental
    end

    tool_rental = ToolRental.find_by(stripe_payment_intent_id: payment_intent.id)
    if tool_rental && payment_intent.payment_method_types.include?('eps')
      ToolRentalService.new.confirm_eps_payment(tool_rental, payment_intent)
      return
    end
  end

  def payment_intent_failed(payment_intent)
    if payment_intent.metadata["pledge_id"]
      crowd_pledge = CrowdPledge.find_by(id: payment_intent.metadata.pledge_id)
      CrowdPledgeService.new.payment_failed(crowd_pledge, payment_intent) if crowd_pledge
    end

    if payment_intent.metadata["room_rental_id"]
      room_rental = RoomRental.find_by(id: payment_intent.metadata.room_rental_id)
      RoomRentalService.new.payment_failed(room_rental, payment_intent) if room_rental
    end

  end

end
