class Coupon < ApplicationRecord
  has_many :coupon_histories
  has_many :subscriptions
  has_many :subscription_invoices
  has_many :users, through: :coupon_histories

  validates :code, presence: true, uniqueness: true
  validates :duration, presence: true

  before_destroy :nullify_associations

  string_enum duration: ["once","forever", "repeating"]

  scope :currently_valid, -> {
    where(enabled: true)
    .where('valid_from IS NULL OR valid_from <= ?', Time.current)
    .where('valid_until IS NULL OR valid_until > ?', Time.current)
  }

  def valid?(product_id = nil)
    return false unless valid_in_system?

    # Prüfe, ob der Coupon auf Produkte eingeschränkt ist (Stripe)
    if product_id.present? && stripe_id.present?
      valid_for_stripe_product?(product_id)
    else
      true # Keine Produktbeschränkung, gültig
    end
  end

  def long_term_coupon?
    forever? || repeating?
  end

  def discount_description
    case duration
    when "once"
      "Rabatt auf die erste Rechnung"
    when "forever"
      "Rabatt (Gutscheincode)"
    when "repeating"
      "Rabatt (Gutscheincode)"
    else
      "Rabatt (Gutscheincode)"
    end
  end

  private

  # Überprüfen, ob der Coupon im System gültig ist
  def valid_in_system?
    self.enabled && (valid_from.nil? || valid_from <= Time.current) &&
      (valid_until.nil? || valid_until > Time.current)
  end

  # Prüfen, ob der Coupon für ein Stripe-Produkt gültig ist
  def valid_for_stripe_product?(product_id)
    begin
      stripe_coupon = Stripe::Coupon.retrieve({ id: stripe_id, expand: ['applies_to'] })
      
      # Prüfen, ob der Coupon bei Stripe gültig ist
      return false unless stripe_coupon.valid

      # Prüfen, ob der Coupon auf Produkte eingeschränkt ist
      if stripe_coupon.respond_to?(:applies_to) && stripe_coupon.applies_to.present?
        allowed_products = stripe_coupon.applies_to["products"] || []
        allowed_products.include?(product_id)
      else
        true # Keine Einschränkungen, Coupon ist gültig
      end
    rescue Stripe::InvalidRequestError => e
      Rails.logger.error "Stripe Fehler: #{e.message}"
      false
    end
  end

  def nullify_associations
    coupon_histories.update_all(coupon_id: nil)
    subscriptions.update_all(coupon_id: nil)
    subscription_invoices.update_all(coupon_id: nil)
  end
end
