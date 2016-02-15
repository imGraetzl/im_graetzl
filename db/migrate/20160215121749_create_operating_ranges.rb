class CreateOperatingRanges < ActiveRecord::Migration
  def change
    create_table :operating_ranges do |t|
      t.belongs_to :graetzl, index: true
      t.belongs_to :initiative, index: true

      t.timestamps null: false
    end
  end
end
