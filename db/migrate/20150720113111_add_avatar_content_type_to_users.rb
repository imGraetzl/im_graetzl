class AddAvatarContentTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :avatar_content_type, :string
  end
end
