class CreateGraetzls < ActiveRecord::Migration
  def change
    create_table :graetzls do |t|
      t.string :name
      t.string :type, default: 'living'
      t.polygon :area

      t.timestamps
    end
  end
end
