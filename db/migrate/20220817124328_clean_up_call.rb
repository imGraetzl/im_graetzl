class CleanUpCall < ActiveRecord::Migration[6.1]
  def change
    remove_column :groups, :room_call_id
    drop_table :room_call_submission_fields
    drop_table :room_call_submissions
    drop_table :room_call_price_modules
    drop_table :room_call_modules
    drop_table :room_call_prices
    drop_table :room_call_fields
    drop_table :room_calls
  end
end
