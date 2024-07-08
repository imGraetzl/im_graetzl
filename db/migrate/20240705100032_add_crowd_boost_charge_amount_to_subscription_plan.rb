class AddCrowdBoostChargeAmountToSubscriptionPlan < ActiveRecord::Migration[6.1]
  def change
    add_column :subscription_plans, :crowd_boost_charge_amount, :decimal, precision: 10, scale: 2
    add_reference :subscription_plans, :crowd_boost, index: true
    add_column :subscriptions, :crowd_boost_charge_amount, :decimal, precision: 10, scale: 2
    add_reference :subscriptions, :crowd_boost, index: true
  end
end
