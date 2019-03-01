class PaymentController < ApplicationController
  rescue_from Stripe::CardError, with: :catch_exception

  def invoice
    @orderType = 'invoice'
    render :template => '/payment/form/new'
  end

  def charge
    @orderType = 'charge'
    render :template => '/payment/form/new'
  end

  def subscription
    @orderType = 'subscription'
    render :template => '/payment/form/new'
  end

  def mentoring
    @orderType = 'mentoring'
    render :template => '/payment/form/new'
  end

  def create
    if params[:orderType] == 'invoice'
      StripeChargesServices.new(payment_params, current_user).init_invoice
    elsif params[:orderType] == 'charge'
      StripeChargesServices.new(payment_params, current_user).init_charge
    elsif params[:orderType] == 'subscription' || params[:orderType] == 'mentoring'
      StripeChargesServices.new(payment_params, current_user).init_subscription
    end
  end

  private

  def payment_params
    params.permit(
      :stripeToken,
      :stripeEmail,
      :amount,
      :stripeDescription,
      :stripePlan,
      :stripeBillingCycleAnchor,
      :stripeTrialEnd,
      :stripeCancelAtPeriodEnd
    )
  end

  def catch_exception(exception)
    flash[:error] = exception.message
  end
end
