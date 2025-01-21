class AddValidUntilToCouponHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :coupon_histories, :valid_until, :datetime
  end
end
