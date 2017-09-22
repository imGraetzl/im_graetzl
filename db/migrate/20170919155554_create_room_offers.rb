class CreateRoomOffers < ActiveRecord::Migration[5.0]
  def change
    create_table :room_offers do |t|
      t.string :slogan
      t.text :room_description
      t.decimal :total_area, precision: 10, scale: 2
      t.decimal :rented_area, precision: 10, scale: 2
      t.boolean :daily_rent
      t.boolean :longterm_rent
      t.text :owner_description
      t.text :tenant_description
      t.boolean :wants_collaboration
      t.string :slug
      t.belongs_to :user, foreign_key: true
      t.belongs_to :location, foreign_key: true

      t.timestamps
    end
  end
end
