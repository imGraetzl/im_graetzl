context.instance_eval do
  columns do
    column do
      attributes_table do
        row :id
        row(:status){|r| status_tag(r.status)}
        row :via_path
        row :region_id
        row :title
        row :message
        row :url
        row :user
        row :name
        row :email
        row :phone
        row :created_at
      end
    end
  end
end