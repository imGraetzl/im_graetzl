class MergeAddresesToModels < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :address_street, :string
    add_column :users, :address_zip, :string
    add_column :users, :address_city, :string
    add_column :users, :address_coordinates, :geometry
    add_column :users, :address_description, :string

    add_column :meetings, :address_street, :string
    add_column :meetings, :address_zip, :string
    add_column :meetings, :address_city, :string
    add_column :meetings, :address_coordinates, :geometry
    add_column :meetings, :address_description, :string

    add_column :locations, :address_street, :string
    add_column :locations, :address_zip, :string
    add_column :locations, :address_city, :string
    add_column :locations, :address_coordinates, :geometry
    add_column :locations, :address_description, :string

    add_column :room_offers, :address_street, :string
    add_column :room_offers, :address_zip, :string
    add_column :room_offers, :address_city, :string
    add_column :room_offers, :address_coordinates, :geometry
    add_column :room_offers, :address_description, :string

    add_column :room_calls, :address_street, :string
    add_column :room_calls, :address_zip, :string
    add_column :room_calls, :address_city, :string
    add_column :room_calls, :address_coordinates, :geometry
    add_column :room_calls, :address_description, :string

    add_column :tool_offers, :address_street, :string
    add_column :tool_offers, :address_zip, :string
    add_column :tool_offers, :address_city, :string
    add_column :tool_offers, :address_coordinates, :geometry
    add_column :tool_offers, :address_description, :string
  end
end
