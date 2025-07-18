context.instance_eval do
  columns do
    column do
      panel 'Meeting Details' do
        attributes_table_for meeting do
          row :id
          row :region
          row :graetzl
          row :name
          row :entire_region
          row :max_going_tos
          row :online_meeting
          row :online_description
          row(:state){|m| status_tag(m.state)}
          row :event_categories do |e|
            safe_join(
              e.event_categories.map do |category|
                content_tag(:span, link_to(category.title, admin_room_category_path(category))) + ', '
              end
            )
          end
          row :slug
          row :created_at
          row :last_activated_at
          row :location
          row :user
          row :description
          row :starts_at_date
          row(:starts_at_time){|m| m.starts_at_time ? m.starts_at_time.strftime('%H:%M') : nil}
          row(:ends_at_time){|m| m.ends_at_time ? m.ends_at_time.strftime('%H:%M') : nil}
          row :ends_at_date
          row :cover_photo do |m|
            m.cover_photo && image_tag(m.cover_photo_url(:thumb))
          end
          row :images do
            meeting.images.map do |image|
              image_tag image.file_url(:thumb)
            end
          end
        end
      end
      panel 'Address Details' do
        attributes_table_for meeting do
          row :address_street
          row :address_zip
          row :address_city
          row :address_coordinates
          row :address_description
        end
      end
    end
    column do
      panel "#{meeting.attendees.count} TeilnehmerInnen" do
        table_for meeting.going_tos do
          column(:id){|g| g.user.full_name_with_email}
          column(:going_to_date){|g| g.going_to_date}
          column(:created_at){|g| g.created_at}
        end
        span do
          link_to "Alle anzeigen",'/admin/going_tos?q[meeting_id_eq='+meeting.id.to_s+']', class: 'btn-light'
        end
      end
      panel 'Additional Dates' do
        table_for meeting.meeting_additional_dates do
          column(:date){|g| link_to g.starts_at_date, admin_meeting_additional_date_path(g)}
        end
      end
    end
  end
end
