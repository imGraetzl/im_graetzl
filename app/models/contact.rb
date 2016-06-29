class Contact < ActiveRecord::Base
  belongs_to :location

  validates :website, url: true, allow_blank: true
end
