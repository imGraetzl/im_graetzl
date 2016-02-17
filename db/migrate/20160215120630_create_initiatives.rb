class CreateInitiatives < ActiveRecord::Migration
  def change
    create_table :initiatives do |t|
      t.string :name
      t.text :description
      t.string :image_id
      t.string :image_content_type
      t.string :website

      t.timestamps null: false
    end
  end
end
