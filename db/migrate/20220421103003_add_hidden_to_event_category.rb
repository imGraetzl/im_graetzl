class AddHiddenToEventCategory < ActiveRecord::Migration[6.1]
  def change
    add_column :event_categories, :hidden, :boolean, default: false
  end
end
