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

  private


end
