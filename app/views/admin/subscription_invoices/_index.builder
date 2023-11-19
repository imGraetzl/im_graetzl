context.instance_eval do
  selectable_column
  id_column
  column :user
  column(:status){|r| status_tag(r.status)}
  column :amount
  column(:invoice_pdf){|u| link_to 'Rechnung', u.generate_invoice_pdf }
  column :created_at
  actions
end
