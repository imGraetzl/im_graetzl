class CreateRoomDemands < ActiveRecord::Migration[5.0]
  def change
    create_table :room_demands do |t|
      t.boolean :seeking_roommate
      t.string :slogan
      t.decimal :needed_area, precision: 10, scale: 2
      t.boolean :daily_rent
      t.boolean :longterm_rent
      t.text :demand_description
      t.text :personal_description
      t.boolean :wants_collaboration
      t.string :slug
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
