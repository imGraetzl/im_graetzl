context.instance_eval do
  selectable_column
  id_column
  column :region
  column :slogan
  column :user
  column(:comment_count) {|r| r.comments.size }
  column :created_at
  actions
end
