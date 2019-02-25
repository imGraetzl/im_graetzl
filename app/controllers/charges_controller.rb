class ChargesController < ApplicationController
  rescue_from Stripe::CardError, with: :catch_exception
  def new
  end

  def create
    StripeChargesServices.new(charges_params, current_user).init_charge
  end

  private

  def charges_params
    params.permit(:stripeToken, :stripeEmail, :amount, :stripeDescription)
  end

  def catch_exception(exception)
    flash[:error] = exception.message
  end
end
