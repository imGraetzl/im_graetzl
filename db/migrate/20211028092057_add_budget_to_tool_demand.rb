class AddBudgetToToolDemand < ActiveRecord::Migration[6.1]
  def change
    add_column :tool_demands, :budget, :decimal, precision: 10, scale: 2
  end
end
