ActiveAdmin.register Location do
  menu priority: 2

  scope 'Alle', :all, default: true
  scope :basic
  scope :pending
  scope :managed

  permit_params :graetzl_id, :state,
    :name,
    :slogan,
    :description,
    :avatar, :remove_avatar,
    :cover_photo, :remove_cover_photo,
    contact_attributes: [
      :website,
      :email,
      :phone],
    address_attributes: [
      :street_name,
      :street_number,
      :zip,
      :city,
      :coordinates],
    user_ids: []


  index do
    selectable_column
    column('Location', sortable: :name) do |location|
      link_to location.name, admin_location_path(location)
    end
    column(:graetzl)
    column('Status') do |location|
      status_tag(location.state)
    end
    column('User') do |location|
      location.users.each do |user|
        a user.username, href: admin_user_path(user)
        text_node ', '.html_safe
      end
    end
    column('Letztes Update', :updated_at)
  end


  show do
    columns do
      column do
        panel 'Basic Info' do
          attributes_table_for location do
            row :status do |location|
              status_tag location.state
            end
            row :id
            row :graetzl
            row :name
            row :slogan
            row :description
            row :cover_photo do |location|
              if location.cover_photo
                image_tag attachment_url(location, :cover_photo, :fill, 200, 100)
              else
                'nicht vorhanden'
              end
            end
            row :avatar do |location|
              if location.avatar
                image_tag attachment_url(location, :avatar, :fill, 100, 100)
              else
                'nicht vorhanden'
              end
            end
          end
        end

        if location.contact
          panel 'Kontakt' do
            attributes_table_for location.contact do
              row :website
              row :email
              row :phone
            end
          end
        end

        if location.address
          panel 'Adresse' do
            attributes_table_for location.address do
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
        panel 'Inhaber' do
          table_for location.location_ownerships do
            column 'Anfrage' do |ownership|
              link_to "Anfrage ##{ownership.id}", admin_location_ownership_path(ownership)
            end
            column 'Status' do |ownership|
              status_tag ownership.state
            end
            column 'User' do |ownership|
              link_to "#{ownership.user.username} (#{ownership.user.first_name} #{ownership.user.last_name})", admin_user_path(ownership.user)
            end
            column 'Email' do |ownership|
              mail_to ownership.user.email
            end
            column 'Erstellt:' do |ownership| 
              I18n.l ownership.created_at
            end
          end
        end
      end
    end
    active_admin_comments
  end

  # form
  form do |f|
    inputs 'Basic Info' do
      input :graetzl
      input :state, as: :select, collection: Location.states.keys
      input :name
      input :slogan
      input :description
      input :cover_photo, as: :file,
        hint: image_tag(attachment_url(f.object, :cover_photo, :fill, 200, 100))
      input :remove_cover_photo, as: :boolean if f.object.cover_photo
      input :avatar, as: :file, hint: image_tag(attachment_url(f.object, :avatar, :fill, 100, 100))
      input :remove_avatar, as: :boolean if f.object.avatar
    end
    inputs 'Kontakt', for: [:contact, (f.object.contact || f.object.build_contact)] do |c|
      c.input :website, as: :url
      c.input :email, as: :email
      c.input :phone
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
    actions
  end


  # batch actions
  batch_action :approve do |ids|
    batch_action_collection.find(ids).each do |location|
      location.approve
    end
    redirect_to collection_path, alert: 'Die ausgewählten Locations wurden freigeschalten.'
  end

  batch_action :reject, confirm: 'Wirklich alle ablehnen?' do |ids|
    batch_action_collection.find(ids).each do |location|
      location.reject
    end
    redirect_to collection_path, alert: 'Die ausgewählten Locations wurden abgelehnt.'
  end


  # action buttons
  action_item :approve, only: :show, if: proc{ location.pending? } do
    link_to 'Location Freischalten', approve_admin_location_path(location), { method: :put }
  end

  action_item :reject, only: :show, if: proc{ location.pending? } do
    link_to 'Location Ablehnen', reject_admin_location_path(location), { method: :put }
  end


  # member actions
  member_action :approve, method: :put do
    if resource.approve
      flash[:success] = 'Location wurde freigeschalten.'
      redirect_to admin_locations_path
    else
      flash[:error] = 'Location kann nicht freigeschalten werden.'
      redirect_to resource_path
    end
  end

  member_action :reject, method: :put do
    if resource.reject
      flash[:notice] = 'Location wurde abgelehnt.'
      redirect_to admin_locations_path
    else
      flash[:error] = 'Location kann nicht abgelehnt werden.'
      redirect_to resource_path
    end
  end
end
