class Post < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  include PublicActivity::Common

  # associations
  belongs_to :graetzl
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy
  accepts_attachments_for :images, attachment: :image

  # validations
  validates :content, presence: true
  validates :graetzl, presence: true
  validates :user, presence: true
end
