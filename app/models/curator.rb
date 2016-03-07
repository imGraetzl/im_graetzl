class Curator < ActiveRecord::Base
  belongs_to :graetzl
  belongs_to :user

  validates :graetzl, presence: true
  validates :user, presence: true
  validates :name, presence: true
  validates :website, presence: true
  validates_format_of :website, with: URI::regexp(%w(http https))
end
