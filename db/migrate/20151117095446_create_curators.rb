class CreateCurators < ActiveRecord::Migration
  def change
    create_table :curators do |t|
      t.belongs_to :graetzl, index: true
      t.belongs_to :user, index: true
      t.string :website
      t.text :description

      t.timestamps null: false
    end
  end
end
