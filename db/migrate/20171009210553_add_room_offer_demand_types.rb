class AddRoomOfferDemandTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :room_offers, :offer_type, :integer, default: 0
    add_column :room_demands, :demand_type, :integer, default: 0
    remove_column :room_demands, :seeking_roommate, :boolean

    create_table :room_suggested_tags do |t|
      t.string :name
      t.timestamps
    end
  end
end
