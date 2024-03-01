class AddStartDateToZuckerls < ActiveRecord::Migration[6.1]
  def change
    add_column :zuckerls, :starts_at, :date
    add_column :zuckerls, :ends_at, :date
  end
end
