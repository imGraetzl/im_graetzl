PublicActivity::Activity.class_eval do
  # These are hacks to be able to use `joins` on the `trackable` polymorphic association.

  belongs_to :post, -> { includes(:activities).where(activities: { trackable_type: 'Post' }) }, foreign_key: :trackable_id
  belongs_to :meeting, -> { includes(:activities).where(activities: { trackable_type: 'Meeting' }) }, foreign_key: :trackable_id
end