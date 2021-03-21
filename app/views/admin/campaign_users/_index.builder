context.instance_eval do
  selectable_column
  id_column
  column :campaign_title
  column :first_name
  column :last_name
  column :email
  column :zip
  column :city
  actions
end
