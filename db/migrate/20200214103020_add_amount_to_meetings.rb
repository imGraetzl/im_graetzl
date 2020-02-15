class AddAmountToMeetings < ActiveRecord::Migration[5.2]
  def change
    add_column :meetings, :chargeable, :boolean, default: false
    add_column :meetings, :amount, :integer, default: 0
  end
end
