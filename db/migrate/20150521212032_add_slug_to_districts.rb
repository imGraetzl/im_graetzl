class AddSlugToDistricts < ActiveRecord::Migration
  def change
    add_column :districts, :slug, :string, unique: true
    add_index :districts, :slug
  end
end