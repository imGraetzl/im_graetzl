context.instance_eval do
  columns do
    column do
      panel 'Basic Details' do
        attributes_table_for group do
          row :id
          row(:group_members_count) { group.group_users.count }
          row :title
          row :description
          row :featured
          row :hidden
          row :room_offer
          row :room_demand
          row :room_call
          row :location
          row :private
          row :created_at
          row :updated_at
        end
      end
    end
    column do
      panel "Themen" do
        table_for group.discussions do
          column :title
          column(''){|l| link_to 'Anzeigen', admin_discussion_path(l) }
        end
      end
    end
  end

  panel "#{group.group_users.size} Gruppenmitglieder / #{group.active_members.size} aktive" do
    if group.default_joined?
      "Zu viele User um anzuzeigen ..."
    else
      table_for group.group_users do
        column :user
        column("Email") { |f| f.user.email }
        column :role
      end
    end
  end

end
