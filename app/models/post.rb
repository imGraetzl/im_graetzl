class Post < ActiveRecord::Base
  include PublicActivity::Common
  extend FriendlyId

  # scopes
  default_scope { order(created_at: :desc) }

  # macros
  friendly_id :date_and_snippet

  # associations
  belongs_to :graetzl
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy
  accepts_attachments_for :images, attachment: :file

  # validations
  validates :content, presence: true
  validates :graetzl, presence: true
  validates :user, presence: true

  # instance methods
  def date_and_snippet
    "#{Time.now.strftime('%m')} #{Time.now.strftime('%Y')} #{content[0..20]}..."
  end
end
