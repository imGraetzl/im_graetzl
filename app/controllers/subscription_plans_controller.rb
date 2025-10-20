class SubscriptionPlansController < ApplicationController

  def show
    @plans = SubscriptionPlan.enabled.in(current_region).all
    @subscriptions = Subscription.active.includes(user: :graetzl).order(created_at: :desc)
    @subscription_count = @subscriptions.size
  end

end
