class SubscriptionPlansController < ApplicationController

  def show
    @plans = SubscriptionPlan.all
  end

end
