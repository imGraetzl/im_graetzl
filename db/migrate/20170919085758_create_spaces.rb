class CreateSpaces < ActiveRecord::Migration[5.0]
  def change
    create_table :spaces do |t|
      t.string :slug
      t.string :slogan
      t.text :description
      t.integer :total_area
      t.integer :rented_area
      t.boolean :daily
      t.boolean :longterm
      t.text :owner_description
      t.text :tenant_description
      t.boolean :collaboration
      t.belongs_to :location, foreign_key: true

      t.timestamps
    end
  end
end
