class ToolRental < ApplicationRecord
  belongs_to :user
  belongs_to :tool_offer

  enum status: { pending: 0, canceled: 1, rejected: 2, accepted: 3 }


end
