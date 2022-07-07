class AddPaymentMethodIdToRoomRental < ActiveRecord::Migration[6.1]
  def change
    add_column :room_rentals, :stripe_payment_method_id, :string
    add_column :tool_rentals, :stripe_payment_method_id, :string
    add_column :room_rentals, :debited_at, :datetime
    add_column :tool_rentals, :debited_at, :datetime
  end
end
