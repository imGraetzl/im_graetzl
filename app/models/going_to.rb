class GoingTo < ApplicationRecord
  belongs_to :user
  belongs_to :meeting
  belongs_to :meeting_additional_date

  enum role: { attendee: 0, initiator: 1, paid_attendee: 2 }
end
