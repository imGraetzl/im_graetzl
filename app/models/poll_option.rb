class PollOption < ApplicationRecord

  belongs_to :poll_question
  has_many :poll_user_answers, dependent: :destroy

  validates_presence_of :title

  def to_s
    title
  end

  def single?
    poll_question.single?
  end

  def multiple?
    poll_question.multiple?
  end

  def free_answer?
    poll_question.free_answer?
  end
  
  def percentage
    total_unique_voters = poll_question.unique_voter_count
    return 0 if total_unique_voters.zero?

    ((votes_count.to_f / total_unique_voters) * 100).round
  end

  private

end
