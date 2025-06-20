class DropLocationOwnershipsTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :location_ownerships
  end
end
