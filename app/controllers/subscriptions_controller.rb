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
    current_user.update(user_params) if params[:user].present?
    @plan = SubscriptionPlan.find_by(id: subscription_params[:subscription_plan_id])
    @subscription = current_user.subscriptions.build(
      subscription_params.merge(
        stripe_plan: @plan.stripe_id,
        region_id: current_user.region_id,
        crowd_boost_charge_amount: @plan.crowd_boost_charge_amount,
        crowd_boost_id: @plan.crowd_boost_id
      )
    )

    coupon_code = subscription_params[:coupon_code]

    if coupon_code.present?
      coupon = Coupon.find_by(code: coupon_code)
      unless coupon&.valid?(@plan.stripe_product_id)
        redirect_to new_subscription_path(subscription_plan_id: @plan.id), notice: "Der Gutscheincode ist ungültig oder nicht für dieses Produkt gültig." and return
      end
    end

    # Speichere die Subscription nur, wenn der Gutscheincode gültig ist oder keiner angegeben wurde
    if @subscription.save

      subscription = SubscriptionService.new.create(@subscription, coupon: coupon_code.presence)
      invoice = subscription.latest_invoice

      if coupon_code.present? && coupon
        @subscription.update(coupon: coupon)
      end

      if invoice.amount_due > 0
        redirect_to choose_payment_subscription_path(@subscription)
      else
        SubscriptionMailer.created(@subscription).deliver_later
        redirect_to [:summary, @subscription]
      end

    else
      # Fehler beim Speichern der Subscription
      render :new
    end
  end

  def choose_payment
    @subscription = current_user.subscriptions.find_by_id(params[:id])
    @plan = @subscription.subscription_plan
    @setup_intent = UserService.new.create_setup_intent(current_user)
  end

  def payment_authorized
    @subscription = current_user.subscriptions.find_by_id(params[:id])
    redirect_to [:choose_payment, @subscription] if params[:setup_intent].blank?

    success, error = UserService.new.payment_authorized(current_user, params[:setup_intent])

    if success
      begin
        SubscriptionService.new.finalize_invoice(@subscription)
  
        flash[:notice] = "Deine Zahlung wurde erfolgreich autorisiert."
        @subscription.reload
  
        previous_subscriptions = current_user.subscriptions.active.where.not(id: @subscription.id)
        previous_subscriptions.each(&:cancel_now!) if previous_subscriptions.present?

        SubscriptionMailer.created(@subscription).deliver_later
  
        redirect_to [:summary, @subscription]
      rescue => e
        flash[:error] = "Zahlung konnte nicht abgeschlossen werden: #{e.message}"
        redirect_to [:choose_payment, @subscription]
      end
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
      :coupon_code
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
