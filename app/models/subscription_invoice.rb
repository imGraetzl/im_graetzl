class SubscriptionInvoice < ApplicationRecord
  belongs_to :user
  belongs_to :subscription
  belongs_to :crowd_boost, optional: true
  has_one :crowd_boost_charge

  scope :sorted, -> { order(created_at: :desc) }
  scope :initialized, -> { where.not(status: :uncollectible) }
  scope :paid, -> { where("amount > 0").and(where(status: :paid)) }
  scope :open, -> { where(status: :open) }
  scope :free, -> { where("amount = 0") }
  scope :refunded, -> { where(status: :refunded) }
  scope :uncollectible, -> { where(status: :uncollectible) }

  after_create :create_crowd_boost_charge, if: -> { crowd_boost_charge_amount && crowd_boost_charge_amount > 0 }
  after_save :update_crowd_boost_charge, if: -> { crowd_boost_charge.present? && saved_change_to_status? }

  default_scope -> { sorted }

  def generate_invoice_pdf
    invoice = Stripe::Invoice.retrieve(stripe_id)
    invoice.invoice_pdf
  rescue => error
    false
  end

  private

  def create_crowd_boost_charge
    CrowdBoostService.new.create_charge_from(self)
    SubscriptionService.new.update_payment_intent(self)
  end

  def update_crowd_boost_charge
    case self.status
    when 'paid'
      self.crowd_boost_charge.update(payment_status: 'debited', debited_at: Time.now)
    when 'refunded'
      self.crowd_boost_charge.update(payment_status: 'refunded')
    when 'uncollectible'
      self.crowd_boost_charge.update(payment_status: 'uncollectible')
    else
      false
    end
  end

end
