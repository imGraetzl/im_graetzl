ActiveAdmin.register_page "Dashboard" do
  menu priority: 1

  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Neue User" do
          table_for User.registered.includes(:graetzl).order(created_at: :desc).limit(10) do
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
      
        panel "Neue Crowdfunding Kampagnen" do
          table_for CrowdCampaign.where(status: [:draft, :re_draft, :pending]).includes(:user).order(created_at: :desc).limit(5) do
            column :id
            #column :region
            column('Start', sortable: :startdate) do |c|
              I18n.localize(c.startdate, format: '%d.%m.%y') if c.startdate?
            end
            column("Status") do |c|
              status_tag(c.status)
            end
            column :title do |c|
              link_to c.title, admin_crowd_campaign_path(c)
            end
            column("Erstellt am") do |c|
              c.created_at.strftime("%d.%m.%Y")
            end
          end
          span do
            link_to 'Zu den Kampagnen', admin_crowd_campaigns_path, class: 'btn-light'
          end
        end
      end

      column do
        panel 'Offene Location Anfragen' do
          table_for Location.pending.includes(:user).order(updated_at: :asc) do
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
