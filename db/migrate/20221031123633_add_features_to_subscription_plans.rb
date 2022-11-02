class AddFeaturesToSubscriptionPlans < ActiveRecord::Migration[6.1]
  def change
    add_column :subscription_plans, :benefit_1, :string
    add_column :subscription_plans, :benefit_2, :string
    add_column :subscription_plans, :benefit_3, :string
    add_column :subscription_plans, :benefit_4, :string
    add_column :subscription_plans, :benefit_5, :string
  end
end
