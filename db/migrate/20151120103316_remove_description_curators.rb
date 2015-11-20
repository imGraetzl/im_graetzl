class RemoveDescriptionCurators < ActiveRecord::Migration
  def change
    remove_column :curators, :description, :string
  end
end
