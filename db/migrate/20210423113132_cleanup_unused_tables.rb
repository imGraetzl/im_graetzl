class CleanupUnusedTables < ActiveRecord::Migration[6.1]
  def change
    drop_table :curators
    remove_column :zuckerls, :initiative_id
    drop_table :initiatives
    drop_table :operating_ranges
    rename_table :posts, :location_posts
    remove_column :group_join_requests, :rejected
    remove_column :location_posts, :type
    rename_column :location_posts, :author_id, :location_id
    add_column :locations, :user_id, :integer
    add_index :locations, :user_id
    add_column :users, :address_id, :integer
    add_index :users, :address_id
    add_column :locations, :address_id, :integer
    add_index :locations, :address_id
    add_column :meetings, :address_id, :integer
    add_index :meetings, :address_id
    add_column :room_offers, :address_id, :integer
    add_index :room_offers, :address_id
    add_column :room_calls, :address_id, :integer
    add_index :room_calls, :address_id
    add_column :tool_offers, :address_id, :integer
    add_index :tool_offers, :address_id
    add_column :meetings, :online_description, :text
  end

end
