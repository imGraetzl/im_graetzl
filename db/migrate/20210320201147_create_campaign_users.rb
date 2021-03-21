class CreateCampaignUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :campaign_users do |t|
      t.string :campaign_title
      t.string :first_name
      t.string :last_name
      t.string :email, default: "", null: false
      t.string :website
      t.string :zip
      t.string :city

      t.timestamps
    end
  end
end
