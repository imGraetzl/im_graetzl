class AddCouponToSubscription < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :coupon, :string
  end
end
