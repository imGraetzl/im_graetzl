context.instance_eval do
  selectable_column
  id_column
  column :name
  column(:state){ |l| status_tag(l.state) }
  column(:location_type){ |l| status_tag(l.location_type) }
  column :slug
  column :graetzl
  column('User') do |location|
    location.users.each do |user|
      a user.username, href: admin_user_path(user)
      text_node '|'.html_safe
    end
  end
  column :updated_at
  actions
end
