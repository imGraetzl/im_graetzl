class AddDefaultRoleToGoingTos < ActiveRecord::Migration
  def change
    change_column :going_tos, :role, :integer, default: 0
  end
end
