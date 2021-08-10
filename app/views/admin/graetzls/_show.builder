context.instance_eval do
  columns do
    column do
      panel 'Basic Details' do
        attributes_table_for graetzl do
          row :id
          row :region
          row :name
          row :slug
          row :created_at
          row :updated_at
          row :area
        end
      end
    end
    column span: 2 do
      panel 'User' do
        table_for graetzl.users do
          column :id
          column :username
          column :email
          column :last_sign_in_at
          column(''){|u| link_to 'Anzeigen', admin_user_path(u) }
        end
      end
    end
  end
end
