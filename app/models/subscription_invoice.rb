class SubscriptionInvoice < ApplicationRecord
  belongs_to :user

  scope :sorted, ->{ order(created_at: :desc) }
  default_scope ->{ sorted }

end
