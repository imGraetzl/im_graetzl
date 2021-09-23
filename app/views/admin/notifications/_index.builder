context.instance_eval do
  selectable_column
  id_column
  column(:type_id){ |a| a.subject_id }
  column :type
  column :user
  column :created_at
  column :sent
  column :notify_at
  column :notify_before
end
