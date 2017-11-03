class CreateDistrictGraetzls < ActiveRecord::Migration[5.0]
  def change
    create_table :district_graetzls do |t|
      t.references :district, foreign_key: true, index: true
      t.references :graetzl, foreign_key: true, index: true
    end
  end
end
