ActiveAdmin.register Meeting do
  include SharedAdmin

  scope :all, default: true
  scope :upcoming
  scope :past

  permit_params :graetzl_id,
    :name,
    :slug,
    :description,
    :cover_photo, :remove_cover_photo,
    :starts_at_date, :starts_at_time,
    :ends_at_date, :ends_at_time,
    :location_id,
    address_attributes: [
      :id,
      :street_name,
      :street_number,
      :zip,
      :city,
      :coordinates,
      :description],
    going_tos_attributes: [
      :id,
      :user_id,
      :_destroy],
    categorizations_attributes: [
      :id,
      :category_id,
      :_destroy]

  index do
    selectable_column
    column :name
    column :graetzl
    column :initiator
    column :location
    column :created_at
    column :updated_at
    actions
  end


  show do
    columns do
      column do
        panel 'Basic Info' do
          attributes_table_for meeting do
            row :id
            row :slug
            row :graetzl
            row :location
            row :name
            row :initiator
            row :description
            row :cover_photo do |meeting|
              if meeting.cover_photo
                image_tag attachment_url(meeting, :cover_photo, :fill, 200, 100)
              else
                'nicht vorhanden'
              end
            end
            row :starts_at_date
            row :starts_at_time
            row :ends_at_date
            row :ends_at_time
          end
        end

        if meeting.address
          panel 'Adresse' do
            attributes_table_for meeting.address do
              row :description
              row 'Straße' do |address|
                text_node "#{address.street_name}, #{address.street_number}".html_safe
              end
              row 'Ort' do |address|
                text_node "#{address.zip}, #{address.city}".html_safe
              end
            end
          end
        end
      end

      column do
        panel 'Teilnehmer' do
          table_for meeting.going_tos do
            column :user
            column :created_at
          end
        end
      end
    end
    active_admin_comments
  end

  form do |f|
    columns do
      column do
        semantic_errors *f.object.errors.keys
        inputs 'Treffen' do
          input :graetzl
          input :name
          input :slug if f.object.persisted?
          input :description
          input :cover_photo, as: :file,
            hint: image_tag(attachment_url(f.object, :cover_photo, :fill, 200, 100))
          input :remove_cover_photo, as: :boolean if f.object.cover_photo
          input :starts_at_date
          input :starts_at_time
          input :ends_at_date
          input :ends_at_time
        end
        inputs 'Location' do
          input :location
        end
        inputs 'Adresse', for: [:address, (f.object.address || f.object.build_address)] do |a|
          a.input :street_name
          a.input :street_number
          a.input :description
          a.input :zip
          a.input :city
          a.input :coordinates, as: :string,
            placeholder: 'POINT (16.345169051785824 48.19314778332606)',
            hint: 'POINT (16.345169051785824 48.19314778332606)'
        end
        inputs 'Kategorien' do
          has_many :categorizations, allow_destroy: true, heading: 'Kategorien', new_record: 'Kategorie Hinzufügen' do |c|
            c.input :category, as: :select, collection: Category.recreation
          end
        end
        actions
      end
      column do
        inputs 'Teilnehmer' do
          has_many :going_tos, allow_destroy: true, heading: false, new_record: 'Neuer Teilnehmer' do |o|
            o.input :user
          end
        end
      end
    end
  end
end