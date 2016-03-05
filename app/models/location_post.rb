class LocationPost < Post
  belongs_to :graetzl

  validates :graetzl, presence: true

  def edit_permission?(user)
    super || (author.users.include? user)
  end
end
