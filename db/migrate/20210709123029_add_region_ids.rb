class AddRegionIds < ActiveRecord::Migration[6.1]
  def change
    add_column :api_accounts, :region_id, :string
    add_column :groups, :region_id, :string
    add_column :locations, :region_id, :string
    add_column :meetings, :region_id, :string
    add_column :room_calls, :region_id, :string
    add_column :room_offers, :region_id, :string
    add_column :room_demands, :region_id, :string
    add_column :tool_offers, :region_id, :string
    add_column :users, :region_id, :string
    add_column :room_rentals, :region_id, :string
    add_column :tool_rentals, :region_id, :string

    add_index :api_accounts, :region_id
    add_index :groups, :region_id
    add_index :locations, :region_id
    add_index :meetings, :region_id
    add_index :room_calls, :region_id
    add_index :room_offers, :region_id
    add_index :room_demands, :region_id
    add_index :tool_offers, :region_id
    add_index :users, :region_id
    add_index :room_rentals, :region_id
    add_index :tool_rentals, :region_id

  end
end
