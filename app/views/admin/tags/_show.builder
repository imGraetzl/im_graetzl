context.instance_eval do
  columns do
    column do
      panel 'Tag' do
        attributes_table_for tag do
          row :id
          row :name
          row :taggings_count
        end
      end
    end
    column span: 2 do
      panel 'Locations' do
        table_for Location.tagged_with(tag.to_s) do
          column :id
          column :name
          column(:state){|l| status_tag(l.state)}
          column(''){|l| link_to 'Location Anzeigen', admin_location_path(l) }
        end
      end
    end
  end
end
