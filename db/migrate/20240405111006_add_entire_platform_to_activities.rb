class AddEntirePlatformToActivities < ActiveRecord::Migration[6.1]
  def change
    add_column :activities, :entire_platform, :boolean, default: false, null: false
  end
end
