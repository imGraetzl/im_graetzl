class AddInvoiceNumberToCrowdCampaign < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_campaigns, :invoice_number, :string
  end
end
