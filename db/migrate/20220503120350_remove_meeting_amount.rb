class RemoveMeetingAmount < ActiveRecord::Migration[6.1]
  def change
    remove_column :meetings, :amount
  end
end
