class Comment < ActiveRecord::Base
  include Trackable

  # default_scope { order(created_at: :desc) }

  # macros
  attr_accessor :inline

  # associations
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  has_many :images, as: :imageable, dependent: :destroy
  accepts_attachments_for :images, attachment: :file

  # validations
  validates :content, presence: true

  # callbacks
  before_destroy :destroy_activity_and_notifications, prepend: true


  def edit_permission?(user)
    user.admin? || (self.user == user) || (commentable.is_a?(User) && (commentable == user))
  end

  private

  def destroy_activity_and_notifications
    activity = Activity.where(recipient: self)
    notifications = Notification.where(activity: activity)
    notifications.destroy_all
    activity.destroy_all
  end
end
