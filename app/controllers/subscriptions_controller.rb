class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def index
    redirect_to subscription_plans_path
  end

  def show
    redirect_to subscription_user_path
  end

  def new
    redirect_to subscription_plans_path, notice: "Du hast bereits eine Mitgliedschaft." and return if current_user.subscribed?

    @plan = SubscriptionPlan.find_by(id: params[:subscription_plan_id])
    @subscription = current_user.subscriptions.build(initial_params)
  end

  def create
    @plan = SubscriptionPlan.find_by(id: subscription_params[:subscription_plan_id])
    @subscription = current_user.subscriptions.build(
      subscription_params.merge(
        stripe_plan: @plan.stripe_id,
        region_id: current_user.region_id,
      )
    )
    if @subscription.save
      current_user.update(user_params) if params[:user].present?
      subscription = SubscriptionService.new.create(@subscription) # Create Stripe Subscription
      if subscription.latest_invoice.payment_intent
        redirect_to [:choose_payment, @subscription, client_secret: subscription.latest_invoice.payment_intent.client_secret]
      else
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
      flash[:notice] = "Deine Zahlung wurde erfolgreich authorisiert."

      ### Cancel prevoius active Subscriptions if exists (may used for 0,00 € Subscriptioons - May improve this)
      previous_subscriptions = current_user.subscriptions.active.where.not(:id => @subscription.id)
      if previous_subscriptions
        previous_subscriptions.each do |subscription|
          subscription.cancel_now!
        end
      end
      ### END

      Activity.in(current_region).where(:subject_type => 'Subscription').delete_all # Delete Subscription Activities
      ActionProcessor.track(@subscription, :create)
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
    @payment_intent = Stripe::PaymentIntent.retrieve(params[:payment_intent])
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
      :subscription_plan_id
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
