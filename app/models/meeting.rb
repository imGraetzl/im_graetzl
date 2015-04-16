class Meeting < ActiveRecord::Base
  # associations
  has_and_belongs_to_many :graetzls
  has_one :address, as: :addressable, dependent: :destroy
end
