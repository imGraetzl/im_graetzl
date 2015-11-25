class RemoveUserIdPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :user_id, :interger, index: true
  end
end
