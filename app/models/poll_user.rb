class PollUser < ApplicationRecord
  belongs_to :poll
  belongs_to :user
  has_many :poll_user_answers, dependent: :destroy
  accepts_nested_attributes_for :poll_user_answers, allow_destroy: true, reject_if: proc { |attrs|
    attrs['answer'].blank? && attrs['poll_option_id'].blank?
  }
end
