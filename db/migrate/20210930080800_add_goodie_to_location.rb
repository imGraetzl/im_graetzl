class AddGoodieToLocation < ActiveRecord::Migration[6.1]
  def change
    add_column :locations, :goodie, :string
  end
end
