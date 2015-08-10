class AddDefaultStateToLocationOwnerships < ActiveRecord::Migration
  def change
    change_column :location_ownerships, :state, :integer, default: 0
  end
end
