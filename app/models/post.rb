class Post < ActiveRecord::Base
  include PublicActivity::Common
  extend FriendlyId

  # scopes
  default_scope { order(created_at: :desc) }

  # macros
  friendly_id :date_and_snippet

  # associations
  belongs_to :graetzl
  belongs_to :author, polymorphic: true
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy
  accepts_attachments_for :images, attachment: :file
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  # validations
  validates :title, presence: true, if: :author_location?
  validates :content, presence: true, if: :author_user?
  validates :graetzl, presence: true
  validates :author, presence: true

  # callbacks
  before_destroy :destroy_activity_and_notifications, prepend: true

  # instance methods
  def date_and_snippet
    time = created_at || Time.now
    "#{time.strftime('%m')} #{time.strftime('%Y')} #{content[0..20]}..."
  end

  def edit_permission?(user)
    user.admin? || (author == user) || (author.is_a?(Location) && author.users.include?(user))
  end


  private

  def destroy_activity_and_notifications
    activity = PublicActivity::Activity.where(trackable: self)
    notifications = Notification.where(activity: activity)
    notifications.destroy_all
    activity.destroy_all
  end

  def author_user?
    author.is_a?(User)
  end

  def author_location?
    author.is_a?(Location)
  end
end
