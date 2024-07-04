class AddSlotProcessToCrowdBoostSlots < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_boost_slots, :slot_detail_description, :text
    add_column :crowd_boost_slots, :slot_process_description, :text
  end
end
