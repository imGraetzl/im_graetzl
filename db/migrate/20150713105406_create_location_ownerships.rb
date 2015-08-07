class CreateLocationOwnerships < ActiveRecord::Migration
  def change
    create_table :location_ownerships do |t|
      t.belongs_to :user, index: true
      t.belongs_to :location, index: true

      t.timestamps null: false
    end
  end
end
