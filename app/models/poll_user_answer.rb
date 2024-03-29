class PollUserAnswer < ApplicationRecord
  belongs_to :poll_question, optional: true, counter_cache: :votes_count
  belongs_to :poll_option, optional: true, counter_cache: :votes_count
  belongs_to :poll_user

  scope :public_comment, -> { where(public_comment: true) }

end
