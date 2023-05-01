class PollUserAnswer < ApplicationRecord
  belongs_to :poll_question, optional: true
  belongs_to :poll_option, optional: true
  belongs_to :poll_user
end
