class UpdateZuckerls < ActiveRecord::Migration[6.1]
  def change
    add_column :zuckerls, :region_id, :string
    add_index :zuckerls, :region_id
    # add_reference :zuckerls, :user, index: true, foreign_key: { on_delete: :nullify }
    # rename_column :zuckerls, :all_districts, :entire_region
  end
end
