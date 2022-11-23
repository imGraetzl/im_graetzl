class SubscriptionInvoice < ApplicationRecord
  belongs_to :user
  belongs_to :subscription

  scope :sorted, ->{ order(created_at: :desc) }
  default_scope ->{ sorted }

end
