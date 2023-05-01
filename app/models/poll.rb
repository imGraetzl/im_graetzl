class Poll < ApplicationRecord
  include Trackable

  extend FriendlyId
  friendly_id :title, :use => :history

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

  string_enum status: ["enabled", "disabled", "closed"]
  string_enum poll_type: ["Allgemein", "Raumteiler", "Energieteiler"]

  scope :scope_public, -> { where(status: [:open, :closed]) }
  scope :by_currentness, -> { order(created_at: :desc) }

  def self.include_for_box
    includes(:poll_questions, :poll_options, :poll_users)
  end

  def poll_question
    poll_questions.first
  end

  def to_s
    title
  end

  private


end
