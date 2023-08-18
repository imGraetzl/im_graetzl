class PollQuestion < ApplicationRecord

  belongs_to :poll
  has_many :poll_options, dependent: :destroy
  has_many :poll_user_answers, dependent: :destroy
  has_many :poll_users, -> { distinct }, through: :poll_user_answers

  accepts_nested_attributes_for :poll_options, allow_destroy: true, reject_if: :all_blank

  validates_presence_of :title

  scope :scope_options, -> { where(option_type: [:radio_button, :check_box]) }
  scope :scope_free_answer, -> { where(option_type: :free_answer) }

  string_enum option_type: ["radio_button", "check_box", "free_answer"]

  def to_s
    title
  end

  def single?
    option_type === "radio_button"
  end

  def multiple?
    option_type === "check_box"
  end

  def free_answer?
    option_type === "free_answer"
  end


  private


end
