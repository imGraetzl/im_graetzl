class AddContextToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :context, :integer, default: 0
  end
end
