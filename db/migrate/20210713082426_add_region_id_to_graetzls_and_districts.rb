class AddRegionIdToGraetzlsAndDistricts < ActiveRecord::Migration[6.1]
  def change
    add_column :graetzls, :region_id, :string
    add_column :districts, :region_id, :string

    add_index :graetzls, :region_id
    add_index :districts, :region_id
  end
end
