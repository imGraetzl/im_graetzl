class AddStripeSetupIntentToBookings < ActiveRecord::Migration[7.2]
  def change
    unless column_exists?(:bookings, :stripe_setup_intent_id)
      add_column :bookings, :stripe_setup_intent_id, :string
    end

    add_index :bookings, :stripe_setup_intent_id, if_not_exists: true
  end
end
