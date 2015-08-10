class CreateCategorizations < ActiveRecord::Migration
  def change
    create_table :categorizations do |t|
      t.belongs_to :category, index: true
      t.references :categorizable, polymorphic: true
      t.timestamps null: false
    end
    add_index :categorizations, [:categorizable_type, :categorizable_id], name: 'idx_categorizations_on_categorizable' 
  end
end
