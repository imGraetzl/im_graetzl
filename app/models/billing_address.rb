class BillingAddress < ActiveRecord::Base
  belongs_to :location

  validates :location, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
end
