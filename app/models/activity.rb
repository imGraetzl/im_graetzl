class Activity < ActiveRecord::Base
  belongs_to :trackable, polymorphic: true
  belongs_to :owner, polymorphic: true
  belongs_to :recipient, polymorphic: true
  serialize :parameters, Hash

  # after_commit on: :create do |activity|
  #   Notification.receive_new_activity(activity)
  # end

  before_destroy :destroy_notifications, prepend: true

  private

  def destroy_notifications
    Notification.where(activity: self).destroy_all
  end
end
