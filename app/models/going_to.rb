class GoingTo < ActiveRecord::Base

  # associations
  belongs_to :user
  belongs_to :meeting

  # validations
  validates :user, presence: true
  validates :meeting, presence: true

  ROLES = { initiator: 0, attendee: 1 }
end
