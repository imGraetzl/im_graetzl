context.instance_eval do
  columns do
    panel 'Notification Details' do
      attributes_table_for notifications do
        row :region
        row :anzahl_empfänger do |n|
          "#{Notification.where(:subject_type => n.subject_type).
            where(:subject_id => n.subject_id).
            where(:child_type => n.child_type).
            where(:child_id => n.child_id).count}"
        end
        row :type
        row :ersteller do |n|
          n.subject.user
        end
        row :subject
        row :child_type
        row :child
        row :created_at
        row :notify_at
        row :notify_before
      end
    end
    panel 'User dieser Notification' do
      attributes_table_for notifications do
        row :id
        row :user
        row :sent
        row :seen
        row :display_on_website
      end
    end
  end
end
