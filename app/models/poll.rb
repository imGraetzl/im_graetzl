class Poll < ApplicationRecord
  include Trackable

  extend FriendlyId
  friendly_id :title, :use => :history

  belongs_to :user
  has_many :poll_graetzls
  has_many :graetzls, through: :poll_graetzls
  has_many :districts, -> { distinct }, through: :graetzls
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy
  has_many :meetings

  has_many :poll_questions, dependent: :destroy
  accepts_nested_attributes_for :poll_questions, allow_destroy: true, reject_if: :all_blank

  has_many :poll_options, through: :poll_questions
  has_many :poll_users, dependent: :destroy
  has_many :users, -> { distinct }, through: :poll_users

  include CoverImageUploader::Attachment(:cover_photo)

  validates_presence_of :title, :graetzls, :description

  string_enum status: ["enabled", "disabled"]
  string_enum poll_type: ["Allgemein", "Raumteiler", "Energieteiler"]

  scope :scope_public, -> { where.not(status: :disabled) }
  scope :by_currentness, -> { order(last_activity_at: :desc) }
  scope :by_zip, -> { order(zip: :asc) }

  after_create :set_zip_and_activity
  after_update :destroy_activity_and_notifications, if: -> { disabled? && saved_change_to_status?}

  def open?
    !closed?
  end

  def energieteiler?
    self.poll_type == 'Energieteiler'
  end

  def self.include_for_box
    includes(:poll_questions, :poll_options, :poll_users)
  end

  def main_question
    poll_questions.where(main_question: true).first
  end

  def find_poll_user(user)
    poll_users.where(user_id: user&.id).first
  end

  def to_s
    title
  end

  private

  def set_zip_and_activity
    self.last_activity_at = Time.current
    self.zip = self.districts.sort_by(&:zip).map(&:zip).first
    self.save
  end

end
