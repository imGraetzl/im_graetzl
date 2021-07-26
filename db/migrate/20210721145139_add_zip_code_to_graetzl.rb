class AddZipCodeToGraetzl < ActiveRecord::Migration[6.1]
  def change
    add_column :graetzls, :zip, :string
  end
end
