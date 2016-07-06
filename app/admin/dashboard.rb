ActiveAdmin.register_page "Dashboard" do
  menu priority: 1

  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel 'Offene Location Anfragen' do
          table_for Location.pending.order(updated_at: :asc) do
            column(:location, sortable: :name) do |location|
              link_to location.name, admin_location_path(location)
            end
            column :graetzl
            column :users do |location|
              location.users.map do |user|
                link_to user.username, admin_user_path(user)
              end
            end
            column('status') { |location| status_tag(location.state) }
          end
          span do
            link_to 'Offene Anfragen Bearbeiten', '/admin/locations?scope=offene_anfragen', class: 'btn-light'
          end
        end
      end
      column do
        panel 'Aktuelle Grätzlbotschafter' do
          table_for Curator.order(:id).limit(10) do
            column('Botschafter') { |c| link_to c.id, admin_curator_path(c) }
            column :user
            column :graetzl
          end
        end
      end
    end
  end
end
