class Curator < ActiveRecord::Base

  # associations
  belongs_to :graetzl
  belongs_to :user

  # validations
  validates :graetzl, presence: true
  validates :user, presence: true
  validates :name, presence: true
  validates :website, presence: true
  validates_format_of :website, with: URI::regexp(%w(http https))
end
