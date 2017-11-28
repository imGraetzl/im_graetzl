context.instance_eval do
  selectable_column
  id_column
  column :slogan
  column :created_at
  column :updated_at
  column(:comment_count) {|r| r.comments.size }
  column(:username) {|r| r.user.username }
  column :first_name
  column :last_name
  column :email
  column :demand_type
  column :wants_collaboration
  column(:room_categories) { |r| r.room_categories.map(&:name).join(", ") }
  column :graetzl
  actions
end
