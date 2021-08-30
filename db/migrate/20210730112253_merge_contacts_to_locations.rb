class MergeContactsToLocations < ActiveRecord::Migration[6.1]
  def change
    add_column :locations, :website_url, :string
    add_column :locations, :online_shop_url, :string
    add_column :locations, :email, :string
    add_column :locations, :phone, :string
    add_column :locations, :open_hours, :string
  end
end
