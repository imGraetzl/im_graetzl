class RenameZuckerlImage < ActiveRecord::Migration[6.1]
  def change
    rename_column :zuckerls, :image_data, :cover_photo_data
  end
end
