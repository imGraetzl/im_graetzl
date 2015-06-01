class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :content
      t.belongs_to :graetzl, index: true
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
