class ChangeRoomRentalPaymentStatusToString < ActiveRecord::Migration[6.1]
  def change
    change_column_default :room_rentals, :payment_status, from: 0, to: nil
    change_column :room_rentals, :payment_status, :string
  end
end
