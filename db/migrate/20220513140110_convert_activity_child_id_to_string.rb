class ConvertActivityChildIdToString < ActiveRecord::Migration[6.1]
  def change
    change_column :activities, :child_id, :string
  end
end
