class RemoveToolCategoryParentId < ActiveRecord::Migration[6.1]
  def change
    remove_column :tool_categories, :parent_category_id
  end
end
