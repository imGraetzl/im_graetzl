context.instance_eval do
  #selectable_column
  id_column
  #column(:type_id){ |a| a.subject_id }
  column do |notification|
    notification.type.split('::')[1]
  end
  column :subject
  #column :user
  column :sent
  column :notify_at
  column :notify_before
  column :created_at
  actions
end
