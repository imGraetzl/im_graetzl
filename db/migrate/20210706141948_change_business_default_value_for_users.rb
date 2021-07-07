class ChangeBusinessDefaultValueForUsers < ActiveRecord::Migration[6.1]
  def change
    change_column_default :users, :business, from: false, to: true
  end
end
