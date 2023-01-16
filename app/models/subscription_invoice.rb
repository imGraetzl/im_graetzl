class SubscriptionInvoice < ApplicationRecord
  belongs_to :user
  belongs_to :subscription

  scope :sorted, ->{ order(created_at: :desc) }
  default_scope ->{ sorted }

  def generate_invoice_pdf
    invoice = Stripe::Invoice.retrieve(stripe_id)
    invoice.invoice_pdf
  rescue => error
    false
  end

end
