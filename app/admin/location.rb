ActiveAdmin.register Location do
  menu priority: 2

  scope 'Alle', :all, default: true
  scope :basic
  #scope 'Offene Anfragen', :all_pending
  scope :pending
  scope :managed
  #scope 'Abgelehnt', :rejected

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


  batch_action :approve do |ids|
    batch_action_collection.find(ids).each do |location|
      user = location.users.last
      if location.may_approve?
        #location.approve!(nil, user)
        location.approve!
      end
    end
    redirect_to collection_path, alert: 'Die ausgewählten Locations wurden freigeschalten.'
  end

  batch_action :reject do |ids|
    batch_action_collection.find(ids).each do |location|
      if location.may_reject?
        location.reject!
      end
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
