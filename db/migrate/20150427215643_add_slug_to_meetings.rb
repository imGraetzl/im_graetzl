class AddSlugToMeetings < ActiveRecord::Migration
  def change
    add_column :meetings, :slug, :string, unique: true
    add_index :meetings, :slug
  end
end