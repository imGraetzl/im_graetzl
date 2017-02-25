class Categorization < ApplicationRecord
  belongs_to :categorizable, polymorphic: true
  belongs_to :category
end
