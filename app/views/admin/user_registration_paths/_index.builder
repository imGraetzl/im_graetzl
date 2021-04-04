context.instance_eval do
  column do |user|
    link_to user.username, admin_user_path(user)
  end
  column :origin
  column do |user|
    link_to "Zur Seite", "#{ENV['HOST']}#{user.origin}", target: "blank"
  end
  column :created_at
end
