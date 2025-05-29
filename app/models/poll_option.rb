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
    total_votes = poll_question.poll_options.sum(:votes_count)
    return 0 if total_votes.zero?

    (votes_count.to_f / total_votes * 100).round
  end

  #def percentage
  #  if self.poll_question.votes_count > 0
  #    (self.votes_count * 100 / self.poll_question.poll_users.count * 100) / 100
  #  else
  #    0
  #  end
  #end

  private


end
