class PaymentController < ApplicationController
  before_filter :authenticate_user!, except: [ :raumteiler ]
  rescue_from Stripe::CardError, with: :catch_exception

  def raumteiler
    render :template => '/payment/form/raumteiler'
  end

  def charge
    render :template => '/payment/form/charge'
  end

  def subscription
    render :template => '/payment/form/subscription'
  end

  def mentoring
    render :template => '/payment/form/mentoring'
  end

  def raumteiler_create
    StripeChargesServices.new(payment_params, current_user).init_invoice
    #flash[:success] = payment_params[:amount]
    render :template => '/payment/confirmation'
    puts payment_params[:message]
  end

  def charge_create
    StripeChargesServices.new(payment_params, current_user).init_charge
    render :template => '/payment/confirmation'
  end

  def subscription_create
    StripeChargesServices.new(payment_params, current_user).init_subscription
    render :template => '/payment/confirmation'
  end

  def mentoring_create
    StripeChargesServices.new(payment_params, current_user).init_invoice
    render :template => '/payment/confirmation'
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
      :stripeCancelAtPeriodEnd,
      :message
    )
  end

  def catch_exception(exception)
    flash[:error] = exception.message
  end
end
