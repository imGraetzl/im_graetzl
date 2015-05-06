class GoingTo < ActiveRecord::Base
  belongs_to :user
  belongs_to :meeting

  ROLES = { initiator: 0, attendee: 1 }
end
