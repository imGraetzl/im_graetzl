class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def index
    redirect_to subscription_plans_path
  end

  def show
    redirect_to subscription_user_path
  end

  def new
    if current_user.subscribed?
      redirect_to subscription_plans_path, notice: "Du hast bereits eine Mitgliedschaft. | Du möchtest wechseln? Schrieb uns an #{ActionController::Base.helpers.mail_to(t("region.#{current_region.id}.contact_email"))}" and return
    elsif current_user&.subscription&.past_due?
      redirect_to subscription_plans_path, notice: "Du hast bereits eine Mitgliedschaft (mit einer noch offenen Rechnung). | #{ActionController::Base.helpers.link_to('Zur Mitgliedschaft', subscription_user_url)}" and return
    end

    @plan = SubscriptionPlan.find_by(id: params[:subscription_plan_id])
    @subscription = current_user.subscriptions.build(initial_params)
  end

  def create
    @plan = SubscriptionPlan.find_by(id: subscription_params[:subscription_plan_id])
    @subscription = current_user.subscriptions.build(
      subscription_params.merge(
        stripe_plan: @plan.stripe_id,
        region_id: current_user.region_id,
        crowd_boost_charge_amount: @plan.crowd_boost_charge_amount,
        crowd_boost_id: @plan.crowd_boost_id
      )
    )

    # Valid Coupon used?
    if subscription_params[:coupon].present? && subscription_params[:coupon] != @plan.coupon
      redirect_to new_subscription_path(subscription_plan_id: @plan.id), notice: "Der eingegebene Gutscheincode ist ungültig" and return
    elsif subscription_params[:coupon].present? && subscription_params[:coupon] == @plan.coupon
      valid_coupon = true
    else
      valid_coupon = false
    end

    if @subscription.save
      current_user.update(user_params) if params[:user].present?

      # Create Stripe Subscription
      if valid_coupon
        subscription = SubscriptionService.new.create(@subscription, coupon: subscription_params[:coupon])
      else
        subscription = SubscriptionService.new.create(@subscription)
      end

      if subscription.latest_invoice.payment_intent
        redirect_to [:choose_payment, @subscription, client_secret: subscription.latest_invoice.payment_intent.client_secret]
      else

        # May improve and outsource this or other trigger place
        # Activity.in(current_region).where(:subject_type => 'Subscription').delete_all # Delete Subscription Activities
        # ActionProcessor.track(@subscription, :create)
        SubscriptionMailer.created(@subscription).deliver_later

        redirect_to [:summary, @subscription]
      end
    else
      render :new
    end
  end

  def choose_payment
    @subscription = current_user.subscriptions.find_by_id(params[:id])
    @plan = @subscription.subscription_plan
    @client_secret = params[:client_secret]
  end

  def payment_authorized
    @subscription = current_user.subscriptions.find_by_id(params[:id])
    redirect_to [:choose_payment, @subscription] if params[:payment_intent].blank?

    success, error = SubscriptionService.new.payment_authorized(@subscription, params[:payment_intent])

    if success
      flash[:notice] = "Deine Zahlung wurde erfolgreich autorisiert."

      ### Cancel prevoius active Subscriptions if exists (may used for 0,00 € Subscriptioons - May improve this)
      previous_subscriptions = current_user.subscriptions.active.where.not(:id => @subscription.id)
      if previous_subscriptions
        previous_subscriptions.each do |subscription|
          subscription.cancel_now!
        end
      end
      ### END

      # Activity.in(current_region).where(:subject_type => 'Subscription').delete_all # Delete Subscription Activities
      # ActionProcessor.track(@subscription, :create)
      SubscriptionMailer.created(@subscription).deliver_later

      redirect_to [:summary, @subscription]
    else
      flash[:error] = error
      redirect_to [:choose_payment, @subscription]
    end
  end

  def change_payment
    @subscription = current_user.subscriptions.find_by_id(params[:id])
    @plan = @subscription.subscription_plan
    @payment_intent = Stripe::PaymentIntent.update(
      params[:payment_intent],
      setup_future_usage: 'off_session',
    )
  end

  def payment_changed
    @subscription = current_user.subscriptions.find_by_id(params[:id])
    redirect_to [:summary, @subscription] if params[:payment_intent].blank?

    success, error = SubscriptionService.new.payment_changed(@subscription, params[:payment_intent])

    if success
      flash[:notice] = "Deine Zahlungsmethode wurde erfolgreich authorisiert."
      redirect_to [:summary, @subscription]
    else
      flash[:error] = error
      redirect_to [:change_payment, @subscription]
    end
  end

  def summary
    @subscription = current_user.subscription
    @plan = @subscription.subscription_plan
  end

  def update
    @subscription = current_user.subscription
    @plan = SubscriptionPlan.find_by(id: params[:subscription_plan_id])
    @subscription.swap(@plan)
    redirect_to subscription_path, notice: "Deine Mitgliedschaft wurde geändert."
  end

  def destroy
    current_user.subscription.cancel
    redirect_to subscription_path, notice: "Deine Mitgliedschaft wurde storniert."
  end

  def resume
    current_user.subscription.resume
    redirect_to subscription_path, notice: "Deine Mitgliedschaft wurde fortgesetzt."
  end

  private

  def initial_params
    params.permit(:subscription_plan_id)
  end

  def subscription_params
    params.require(:subscription).permit(
      :stripe_plan,
      :subscription_plan_id,
      :coupon
    )
  end

  def user_params
    params.require(:user).permit(
      billing_address_attributes: [
        :id, :first_name, :last_name, :street, :zip, :city, :country, :company, :vat_id,
      ],
    )
  end

end
