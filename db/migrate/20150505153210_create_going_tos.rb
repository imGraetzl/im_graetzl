class CreateGoingTos < ActiveRecord::Migration
  def change
    create_table :going_tos do |t|
      t.references :user, index: true
      t.references :meeting, index: true
      t.integer :role

      t.timestamps
    end
  end
end
