class AddLastActivityAtToPolls < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :last_activity_at, :datetime
  end
end
