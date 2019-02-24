class ChargesController < ApplicationController
  rescue_from Stripe::CardError, with: :catch_exception
  def new
  end

  def create
    StripeChargesServices.new(charges_params, current_user).call
  end

  private

  def charges_params
    params.permit(:stripeToken, :stripeEmail, :amount)
  end

  def catch_exception(exception)
    flash[:error] = exception.message
  end
end
