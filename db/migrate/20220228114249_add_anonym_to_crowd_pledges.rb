class AddAnonymToCrowdPledges < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_pledges, :anonym, :boolean, default: false
  end
end
