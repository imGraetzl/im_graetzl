class LocationPost < Post
  belongs_to :graetzl

  validates :graetzl, presence: true

  after_create :update_location_activity

  def edit_permission?(user)
    super || (author.users.include? user)
  end

  def update_location_activity
    author.update(last_activity_at: created_at)
  end
end
