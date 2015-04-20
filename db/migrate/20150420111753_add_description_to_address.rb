class AddDescriptionToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :description, :string
  end
end
