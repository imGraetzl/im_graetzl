context.instance_eval do
  column do |user|
    link_to user.username, admin_user_path(user)
  end
  column :origin
  column do |user|
    link_to "Zur Seite", "#{root_url.delete_suffix('/')}#{user.origin}", target: "blank" if user.origin
  end
  column :created_at
end
