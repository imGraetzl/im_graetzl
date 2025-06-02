class AddCommentsEnabledToPolls < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :comments_enabled, :boolean, default: true, null: false
  end
end
