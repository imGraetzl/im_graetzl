class RemoveUnused < ActiveRecord::Migration[6.1]
  def change
    remove_column :location_categories, :context, :integer
    remove_column :locations, :meeting_permission, :integer
    add_column :meetings, :online_url, :string
  end
end
