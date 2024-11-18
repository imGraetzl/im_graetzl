class AddCommentIdToCrowdPledges < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_pledges, :comment_id, :integer

    # Optional: Index hinzufügen, um Suchvorgänge zu beschleunigen
    add_index :crowd_pledges, :comment_id
  end
end
