class AddForeignKeyToCommentsInCrowdPledges < ActiveRecord::Migration[6.1]
  def change
    # Entferne vorhandene `comment_id`-Indizes (falls nötig)
    remove_index :crowd_pledges, :comment_id if index_exists?(:crowd_pledges, :comment_id)
    
    # Fremdschlüssel hinzufügen
    add_foreign_key :crowd_pledges, :comments, column: :comment_id, on_delete: :nullify

    # Optional: Index für `comment_id` wiederherstellen, falls du ihn brauchst
    add_index :crowd_pledges, :comment_id
  end
end
