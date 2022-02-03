context.instance_eval do
  columns do
    column do
      attributes_table do
        row :id
        row :title
        row :position
        row :css_ico_class
        row :slug
        row :created_at
      end
    end
    column span: 2 do
      panel 'Crowdfundings' do
        table_for crowd_category.crowdfundings do
          column :id
          column :title
          column(''){|m| link_to 'Anzeigen', admin_crowdfunding_path(m) }
        end
      end
    end
  end
end
