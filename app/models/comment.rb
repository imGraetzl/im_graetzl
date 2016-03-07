class Comment < ActiveRecord::Base
  attr_accessor :inline

  belongs_to :user
  belongs_to :commentable, polymorphic: true
  has_many :images, as: :imageable, dependent: :destroy
  accepts_attachments_for :images, attachment: :file

  validates :content, presence: true

  before_destroy :destroy_activity_and_notifications, prepend: true

  def edit_permission?(user)
    user.admin? || (self.user == user) || (commentable == user)
  end

  private

  def destroy_activity_and_notifications
    Activity.where(recipient: self).destroy_all
  end
end
