class AddIconToToolCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :tool_categories, :icon, :string
  end
end
