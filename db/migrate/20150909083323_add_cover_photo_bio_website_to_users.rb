class AddCoverPhotoBioWebsiteToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :cover_photo_id
      t.string :cover_photo_content_type
      t.text :bio
      t.string :website
    end
  end
end