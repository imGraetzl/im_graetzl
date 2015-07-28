ActiveAdmin.register Location do
  menu priority: 2

  scope 'Alle', :all, default: true
  scope :basic
  scope 'Pending', :all_pending
  scope :managed

  index do
    selectable_column
    column('ID', sortable: :id) do |location|
      link_to "##{location.id} ", admin_location_path(location)
    end
    column(:name, sortable: :name) do |location|
      link_to location.name, admin_location_path(location)
    end
    column('Status') do |location|
      status_tag(location.state)
    end
    column('Erstellt', :updated_at)
    column('Inhaber') do |location|
      location.users.each do |user|
        a user.username, href: admin_user_path(user)
        text_node ', '.html_safe
      end
    end
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
            row :name
            row :slogan
            row :description
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
            column 'User' do |ownership|
              link_to "#{ownership.user.username} (#{ownership.user.first_name} #{ownership.user.last_name})", admin_user_path(ownership.user)
            end
            column 'Email' do |ownership|
              mail_to ownership.user.email
            end
            column 'Inhaber seit:' do |ownership| 
              I18n.l ownership.created_at
            end
            column 'Status' do |ownership|
              status_tag ownership.state
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
    redirect_to collection_path, alert: 'Die ausgewählten Locations wurden approved.'
  end

  # index do
  #   id_column
  #   column :name
  #   actions
  # end

  # index as: :grid do |location|
  #   link_to location.name, admin_location_path(location)
  # end


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end


end
