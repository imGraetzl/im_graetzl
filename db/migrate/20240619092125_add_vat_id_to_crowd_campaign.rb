class AddVatIdToCrowdCampaign < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :vat_id, :string
  end
end
