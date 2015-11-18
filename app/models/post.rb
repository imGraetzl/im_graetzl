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

  # validations
  validates :content, presence: true
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
    (author == user) || (author.is_a?(Location) && author.users.include?(user))
  end


  private

  def destroy_activity_and_notifications
    activity = PublicActivity::Activity.where(trackable: self)
    notifications = Notification.where(activity: activity)
    notifications.destroy_all
    activity.destroy_all
  end
end
