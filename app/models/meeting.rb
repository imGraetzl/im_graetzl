class Meeting < ActiveRecord::Base
  has_and_belongs_to_many :graetzls
end
