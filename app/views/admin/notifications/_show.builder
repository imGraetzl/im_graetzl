context.instance_eval do
  columns do
    column span: 2 do
      panel 'Notification Details' do
        attributes_table_for notifications do
          row :region
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
    column do
      panel "#{Notification.where(:subject_type => notifications.subject_type).
        where(:subject_id => notifications.subject_id).
        where(:child_type => notifications.child_type).
        where(:child_id => notifications.child_id).count} E-Mail Notification Empfänger" do
        table_for Notification.where(:subject_type => notifications.subject_type).
          where(:subject_id => notifications.subject_id).
          where(:child_type => notifications.child_type).
          where(:child_id => notifications.child_id)  do |n|
            column 'user', n.id
        end
      end
    end
  end
end
