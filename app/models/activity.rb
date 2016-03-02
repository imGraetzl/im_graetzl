class Activity < ActiveRecord::Base
  belongs_to :trackable, polymorphic: true
  belongs_to :owner, polymorphic: true
  belongs_to :recipient, polymorphic: true
  serialize :parameters, Hash

  after_commit on: :create do |activity|
    Notification.receive_new_activity(activity)
  end

  # def self.create_activity(trackable, options)
  #   trackable.activities.create options
  # end
end
