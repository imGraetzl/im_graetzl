class CreateZuckerls < ActiveRecord::Migration
  def change
    create_table :zuckerls do |t|
      t.belongs_to :location, index: true

      t.string :title
      t.text :description
      t.string :image_id
      t.string :image_content_type
      t.boolean :flyer, default: false
      t.string :aasm_state
      t.datetime :paid_at

      t.timestamps null: false
    end
  end
end
