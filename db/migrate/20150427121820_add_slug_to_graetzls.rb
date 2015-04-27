class AddSlugToGraetzls < ActiveRecord::Migration
  def change
    add_column :graetzls, :slug, :string, unique: true
    add_index :graetzls, :slug
  end
end
