class SubscriptionPlansController < ApplicationController

  def show
    @plans = SubscriptionPlan.enabled.in(current_region).all
    @subscriptions = Subscription.in(current_region).active.includes(user: :graetzl).order(created_at: :desc)
  end

end
