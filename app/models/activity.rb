class Activity < ApplicationRecord
  belongs_to :trackable, polymorphic: true
  belongs_to :owner, optional: true, class_name: "User"
  belongs_to :recipient, optional: true, polymorphic: true
  serialize :parameters, Hash

  after_commit on: :create do |activity|
    Notification.delay.broadcast(activity.id)
  end

  def to_s
    "#{trackable_type} (#{trackable_id}) #{key}"
  end

  def appendix
    if key == 'location.create'
      { message: { title: "Neu auf imGrätzl", content: "Sag gleich Hallo!"}}
    elsif key.end_with?('.comment')
      { comment: trackable.comments.last }
    elsif key.end_with?('.go_to')
      { participant: owner }
    else
      {}
    end
  end

end
