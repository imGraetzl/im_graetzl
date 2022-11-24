class AddCouponToSubscriptionPlan < ActiveRecord::Migration[6.1]
  def change
    add_column :subscription_plans, :coupon, :string
  end
end
