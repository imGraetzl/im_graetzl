class SubscriptionInvoice < ApplicationRecord
  belongs_to :user
  belongs_to :subscription

  scope :sorted, -> { order(created_at: :desc) }
  scope :initialized, -> { where.not(status: :uncollectible) }
  scope :paid, -> { where("amount > 0").and(where(status: :paid)) }
  scope :open, -> { where(status: :open) }
  scope :free, -> { where("amount = 0") }
  scope :refunded, -> { where(status: :refunded) }
  scope :uncollectible, -> { where(status: :uncollectible) }

  default_scope -> { sorted }

  def generate_invoice_pdf
    invoice = Stripe::Invoice.retrieve(stripe_id)
    invoice.invoice_pdf
  rescue => error
    false
  end

end
