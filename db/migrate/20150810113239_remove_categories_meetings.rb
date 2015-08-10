class RemoveCategoriesMeetings < ActiveRecord::Migration
  def change
    drop_table :categories_meetings
  end
end
