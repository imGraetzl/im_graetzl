class AddTermsToCrowdPledges < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_pledges, :terms, :boolean, default: false
  end
end
