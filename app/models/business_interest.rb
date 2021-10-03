class BusinessInterest < ApplicationRecord
  validates_presence_of :title

  def to_s
    title
  end

end
