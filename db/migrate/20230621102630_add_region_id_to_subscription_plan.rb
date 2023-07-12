class AddRegionIdToSubscriptionPlan < ActiveRecord::Migration[6.1]
  def change
    add_column :subscription_plans, :region_id, :string
    add_index :subscription_plans, :region_id
  end
end
