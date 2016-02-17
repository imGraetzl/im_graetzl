class AddInitiativeToZuckerls < ActiveRecord::Migration
  def change
    add_column :zuckerls, :initiative_id, :integer
    add_index :zuckerls, :initiative_id
  end
end
