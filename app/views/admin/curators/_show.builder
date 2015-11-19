context.instance_eval do
  columns do
    column do
      panel 'Grätzlbotschafter Details' do
        attributes_table_for curator do
          row :id
          row :graetzl
          row :user
          row :website
          row :description
          row :created_at
          row :updated_at
        end
      end
    end
  end
end
