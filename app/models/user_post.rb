class UserPost < Post
  belongs_to :graetzl

  validates :graetzl, presence: true

  def edit_permission?(user)
    super || (author == user)
  end
end
