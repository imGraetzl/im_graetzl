class AddGraetzlToLocations < ActiveRecord::Migration
  def change
    change_table :locations do |t|
      t.belongs_to :graetzl, index: true
    end
  end
end