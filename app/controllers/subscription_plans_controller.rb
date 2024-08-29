class SubscriptionPlansController < ApplicationController

  def show
    @plans = SubscriptionPlan.enabled.in(current_region).all
    @subscriptions = Subscription.in(current_region).active.includes(:user).order(created_at: :desc)
  end

end
