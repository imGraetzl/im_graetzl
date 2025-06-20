class DropCategoriesMeetingsTable < ActiveRecord::Migration[6.1]
  def change
    if table_exists?(:categories_meetings)
      drop_table :categories_meetings
    end
  end
end
