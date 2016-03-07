class GoingTo < ActiveRecord::Base

  belongs_to :user
  belongs_to :meeting

  enum role: { attendee: 0, initiator: 1 }
end
