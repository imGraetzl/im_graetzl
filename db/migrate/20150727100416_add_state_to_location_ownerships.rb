class AddStateToLocationOwnerships < ActiveRecord::Migration
  def change
    add_column :location_ownerships, :state, :integer
  end
end
