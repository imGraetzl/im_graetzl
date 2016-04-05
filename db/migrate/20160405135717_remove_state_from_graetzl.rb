class RemoveStateFromGraetzl < ActiveRecord::Migration
  def change
    remove_column :graetzls, :state, :integer, default: 0
  end
end
