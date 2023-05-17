context.instance_eval do
  panel 'Umfrage Details' do
    attributes_table_for poll do
      row :id
      row(:status){|m| status_tag(m.status)}
      row :closed
      row :region
      row :title
      row :poll_type
      row :slug
      row :created_at
      row :cover_photo do |m|
        m.cover_photo && image_tag(m.cover_photo_url(:thumb))
      end
    end
  end
  panel 'Antwortmöglichkeiten' do
    table_for poll.poll_options do |p|
      column :id
      column :title
    end
  end
end
