context.instance_eval do
  columns do
    column do
      attributes_table do
        row :id
        row :name
        row :description
        row :image do |i|
          i.image ? attachment_image_tag(i, :image, :fit, 100, 200) : nil
        end
        row :website
        row :graetzls
        row :created_at
        row :updated_at
      end
    end
    column span: 2 do
      panel 'Associations' do
        tabs do
          tab 'Graetzl' do
            table_for initiative.graetzls do
              column(:id){|graetzl| link_to graetzl.id, [:admin, graetzl]}
              column :name
            end
          end
        end
      end
    end
  end
end
