class ChangePledgeStatusToString < ActiveRecord::Migration[6.1]
  def change
    change_column :crowd_pledges, :status, :string
  end
end
