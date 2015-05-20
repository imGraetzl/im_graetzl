class CreateDistricts < ActiveRecord::Migration
  def change
    create_table :districts do |t|
      t.string :name
      t.string :zip
      t.polygon :area

      t.timestamps
    end
  end
end
