class AddStatusToSubscriptionPlan < ActiveRecord::Migration[6.1]
  change_table :subscription_plans do |t|
    t.integer "status", default: 0
  end
end
