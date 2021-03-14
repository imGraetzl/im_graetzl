class AddLastActivityAtToGroupUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :group_users, :last_activity_at, :datetime
  end
end
