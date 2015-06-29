class Comment < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  # associations
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  has_many :images, as: :imageable, dependent: :destroy
  accepts_attachments_for :images, attachment: :file

  # validations
  validates :content, presence: true
end
