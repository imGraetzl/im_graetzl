class AddEmailToCrowdDonationPledges < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_donation_pledges, :email, :string
    add_column :crowd_donation_pledges, :donation_type, :integer
  end
end
