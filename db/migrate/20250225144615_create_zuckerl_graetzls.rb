class CreateZuckerlGraetzls < ActiveRecord::Migration[6.1]
  def change
    create_table :zuckerl_graetzls do |t|
      t.references :zuckerl, null: false, foreign_key: true, index: true
      t.references :graetzl, null: false, foreign_key: true, index: true

      t.timestamps
    end

    # Unique Index um doppelte Einträge zu vermeiden
    add_index :zuckerl_graetzls, [:zuckerl_id, :graetzl_id], unique: true
  end
end
