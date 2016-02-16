class AddSlugToZuckerls < ActiveRecord::Migration
  def change
    add_column :zuckerls, :slug, :string, unique: true
    add_index :zuckerls, :slug
  end
end
