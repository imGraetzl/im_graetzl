class AddEmailToCrowdPledges < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_pledges, :email, :string
  end
end
