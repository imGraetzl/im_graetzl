context.instance_eval do
  selectable_column
  id_column
  column :name
  column :graetzl
  column :user
  #column(:event_categories) { |m| m.event_categories.map(&:title).join(", ") }
  column 'API', :approved_for_api
  actions
end
