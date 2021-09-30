ActiveAdmin.register_page "Dashboard" do
  menu priority: 1

  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Neue User" do
          table_for User.order(created_at: :desc).limit(10) do
            column :id
            column :region
            column :username do |user|
              link_to user.username, admin_user_path(user)
            end
            column :graetzl
            column :created_at
          end
          span do
            link_to 'Alle User anzeigen', admin_users_path, class: 'btn-light'
          end
        end

        panel 'Offene Platform Treffen Anfragen' do
          table_for Meeting.platform_meeting_pending.order(updated_at: :asc) do
            column(:meeting, sortable: :name) do |meeting|
              link_to meeting.name, admin_meeting_path(meeting)
            end
            column :users do |meeting|
              link_to(meeting.user.username, admin_user_path(meeting.user))
            end
            column('status') { |meeting| status_tag(meeting.platform_meeting_join_request.status) }
          end
          span do
            link_to 'Offene Anfragen Bearbeiten', admin_meetings_path(:scope => 'platform_meeting_pending'), class: 'btn-light'
          end
        end

      end
      column do
        panel 'Campaign Users' do
          table_for CampaignUser.order(updated_at: :asc).limit(10) do
            column :campaign_title
            column :first_name
            column :last_name
            column :email
          end
          span do
            link_to 'Alle anzeigen', admin_campaign_users_path, class: 'btn-light'
          end
        end

        panel 'Offene Location Anfragen' do
          table_for Location.pending.order(updated_at: :asc) do
            column :region
            column(:location, sortable: :name) do |location|
              link_to location.name, admin_location_path(location)
            end
            column :user do |location|
              link_to location.user.username, admin_user_path(location.user)
            end
            column('status') { |location| status_tag(location.state) }
          end
          span do
            link_to 'Offene Anfragen Bearbeiten', admin_locations_path(:scope => 'pending'), class: 'btn-light'
          end
        end
      end
    end
  end
end
