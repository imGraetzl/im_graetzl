class ChangeToolRentalPaymentStatusToString < ActiveRecord::Migration[6.1]
  def change
    change_column_default :tool_rentals, :payment_status, from: 0, to: nil
    change_column :tool_rentals, :payment_status, :string
  end
end
