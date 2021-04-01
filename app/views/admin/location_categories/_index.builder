context.instance_eval do
  selectable_column
  id_column
  column :position
  column :name
  column :icon
  column(:context){|c| status_tag(c.context) }
  actions
end
