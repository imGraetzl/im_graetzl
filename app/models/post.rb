class Post < ActiveRecord::Base
  include Trackable
  extend FriendlyId

  default_scope { order(created_at: :desc) }

  friendly_id :title

  belongs_to :author, polymorphic: true
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy
  accepts_attachments_for :images, attachment: :file
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true
  validates :author, presence: true

  def edit_permission?(user)
    user.admin?
  end
  #
  #
  #
  # def author_user?
  #   author.is_a?(User)
  # end
  #
  # def author_location?
  #   author.is_a?(Location)
  # end
end
