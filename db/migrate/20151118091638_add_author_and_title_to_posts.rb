class AddAuthorAndTitleToPosts < ActiveRecord::Migration
  def change
    change_table :posts do |t|
      t.string :title
      t.references :author, polymorphic: true, index: true
    end
  end
end
