class Curator < ApplicationRecord
  belongs_to :graetzl
  belongs_to :user

  validates :graetzl, presence: true
  validates :user, presence: true
  validates :name, presence: true
  validates :website, presence: true
  validates :website, url: true, allow_blank: true
end
