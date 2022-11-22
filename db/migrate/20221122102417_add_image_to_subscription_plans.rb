class AddImageToSubscriptionPlans < ActiveRecord::Migration[6.1]
  def change
    add_column :subscription_plans, :image_url, :string
    rename_column :subscription_plans, :description, :short_name
    change_column :subscription_plans, :short_name, :string
  end
end
