class AddDefaultJoinedToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :default_joined, :boolean, default: false
  end
end
