module Trackable
  extend ActiveSupport::Concern

  included do
    before_destroy :destroy_activity_and_notifications, prepend: true
  end

  def destroy_activity_and_notifications
    Activity.where(subject: self).or(Activity.where(child: self)).destroy_all
    Notification.where(subject: self).or(Notification.where(child: self)).delete_all # Faster / No Callbacks needed
  end

end
