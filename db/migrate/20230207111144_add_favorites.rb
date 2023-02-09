class AddFavorites < ActiveRecord::Migration[6.1]
  def change

    create_table :favorites do |t|
      t.references :favoritable, polymorphic: true, index: true
      t.references :user, index: true, foreign_key: { on_delete: :cascade }
      t.timestamps
    end

    change_column :favorites, :favoritable_type, :string, :limit => 255

  end
end
