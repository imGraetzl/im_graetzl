class AddFreeZuckerlsToSubscriptionPlanAndUser < ActiveRecord::Migration[6.1]
  def change

    add_column :subscription_plans, :free_region_zuckerl, :integer, default: 0
    add_column :subscription_plans, :free_graetzl_zuckerl, :integer, default: 0
    add_column :subscription_plans, :free_region_zuckerl_monthly_interval, :integer, default: 0
    add_column :subscription_plans, :free_graetzl_zuckerl_monthly_interval, :integer, default: 0

    add_column :users, :free_region_zuckerl, :integer, default: 0
    add_column :users, :free_graetzl_zuckerl, :integer, default: 0

  end
end
