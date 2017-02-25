class Contact < ApplicationRecord
  belongs_to :location

  validates :website, url: true, allow_blank: true
end
