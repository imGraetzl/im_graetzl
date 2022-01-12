class AddMessageToRegionCalls < ActiveRecord::Migration[6.1]
  def change
    add_column :region_calls, :message, :text
  end
end
