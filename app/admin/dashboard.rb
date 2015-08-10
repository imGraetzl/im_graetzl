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
            column(:graetzl)
            column('User') do |location|
              location.users.each do |user|
                a user.username, href: admin_user_path(user)
                text_node ', '.html_safe
              end
            end
            column('status') { |location| status_tag(location.state) }
          end

          span do
            link_to 'Offene Anfragen Bearbeiten', '/admin/locations?scope=offene_anfragen', class: 'btn-light'
          end
        end

      #   panel 'Offene Location-Mitarbeiter Anfragen' do
      #     table_for LocationOwnership.requested.order(updated_at: :asc) do
      #       column('Anfrage', sortable: :id) do |ownership|
      #         link_to "Anfrage #{ownership.id} ", admin_location_ownership_path(ownership)
      #       end
      #       column(:location) do |ownership|
      #         link_to ownership.location.name, admin_location_path(ownership.location)
      #       end
      #       column(:user) do |ownership|
      #         link_to ownership.user.username, admin_user_path(ownership.user_id)
      #       end
      #       column('Erstellt', :updated_at)
      #       column('status') { |ownership| status_tag(ownership.state) }
      #     end

      #     span do
      #       link_to 'Anfragen Bearbeiten', '/admin/location_ownerships?scope=pending'
      #     end
      #   end
      end

      column do
        panel 'Neue Adressen' do
          render 'admin/locations/candidates_table', compact: true
        end
      end
    end
  end
end