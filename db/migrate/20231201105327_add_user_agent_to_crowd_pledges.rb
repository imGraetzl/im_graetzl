class AddUserAgentToCrowdPledges < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_pledges, :user_agent, :jsonb
  end
end
