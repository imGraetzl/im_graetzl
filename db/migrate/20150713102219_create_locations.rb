class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.string :slogan
      t.text :description
      t.string :avatar_id
      t.string :cover_photo_id
      t.string :slug, unique: true, index: true

      t.timestamps null: false
    end
  end
end