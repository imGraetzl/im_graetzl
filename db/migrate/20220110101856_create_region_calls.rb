class CreateRegionCalls < ActiveRecord::Migration[6.1]
  def change
    create_table :region_calls do |t|
      t.integer :region_type, default: 0
      t.string :region_id
      t.string :gemeinden
      t.string :name
      t.string :personal_position
      t.string :email, default: "", null: false
      t.string :phone

      t.timestamps
    end
  end
end
