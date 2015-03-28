class RemoveTypeFromGraetzls < ActiveRecord::Migration
  def change
    remove_column :graetzls, :type, :string
  end
end
