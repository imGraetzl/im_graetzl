class UpdateRoomOfferAndDemand < ActiveRecord::Migration[5.0]
  def change
    add_reference :room_offers, :graetzl, foreign_key: true, index: true
    add_reference :room_offers, :district, foreign_key: true, index: true
    add_column :room_offers, :main_image_id, :string
    add_column :room_offers, :main_image_content_type, :string

    create_table :room_categories do |t|
      t.string :name
      t.timestamps
    end

    create_table :room_offer_categories do |t|
      t.belongs_to :room_category, foreign_key: true, index: true
      t.belongs_to :room_demand, foreign_key: true, index: true
    end

    create_table :room_demand_categories do |t|
      t.belongs_to :room_category, foreign_key: true, index: true
      t.belongs_to :room_demand, foreign_key: true, index: true
    end

    create_table :room_demand_graetzls do |t|
      t.belongs_to :graetzl, foreign_key: true, index: true
      t.belongs_to :room_demand, foreign_key: true, index: true
    end

    create_table :room_demand_districts do |t|
      t.belongs_to :district, foreign_key: true, index: true
      t.belongs_to :room_demand, foreign_key: true, index: true
    end

  end
end
