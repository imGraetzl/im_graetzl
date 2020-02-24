class GoingTo < ApplicationRecord
  belongs_to :user
  belongs_to :meeting
  belongs_to :meeting_additional_date

  enum role: { attendee: 0, initiator: 1, paid_attendee: 2 }
  enum payment_status: { payment_pending: 0, payment_success: 1, payment_failed: 2, payment_transfered: 3 }

  PAYMENT_METHODS = ['card', 'eps'].freeze

end
