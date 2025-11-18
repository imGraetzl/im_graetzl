class AddStripeSetupIntentToCrowdPledges < ActiveRecord::Migration[7.2]
  def change
    add_column :crowd_pledges, :stripe_setup_intent_id, :string
    add_column :crowd_pledges, :processing_seen_at, :datetime
    add_index :crowd_pledges, :stripe_setup_intent_id
  end
end
