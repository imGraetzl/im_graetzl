class SubscriptionPlansController < ApplicationController

  def show
    @plans = SubscriptionPlan.all
    @subscriptions = Subscription.in(current_region).active.order(created_at: :desc)
  end

end
