class AddNeighbourlessToGraetzls < ActiveRecord::Migration[6.1]
  def change
    add_column :graetzls, :neighborless, :boolean, default: false
  end
end
