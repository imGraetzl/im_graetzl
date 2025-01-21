class SubscriptionPlan < ApplicationRecord

  belongs_to :crowd_boost, optional: true

  enum status: { enabled: 0, disabled: 1 }
  scope :sorted, ->{ order(amount: :asc) }
  default_scope ->{ sorted }

  def to_s
    name
  end

  def amount_readable
    "#{helper.number_to_currency(amount, unit: "€")} / #{I18n.t("activerecord.attributes.subscription_plan.intervals.#{interval}")}"
  end

  def equals_monthly_price
    amount / 12
  end

  def discounted_equals_monthly_price(amount_off: nil, percent_off: nil)
    discounted_amount(amount_off: amount_off, percent_off: percent_off) / 12
  end

  def discounted_amount(amount_off: nil, percent_off: nil)
    discounted_price = amount
  
    # Betrag in Euro abziehen, falls vorhanden
    if amount_off.present?
      discounted_price -= amount_off
    end
  
    # Prozentualen Rabatt abziehen, falls vorhanden
    if percent_off.present?
      discounted_price -= (discounted_price * percent_off / 100.0).round
    end
  
    # Betrag darf nicht negativ sein
    [discounted_price, 0].max
  end

  private

  def helper
    @helper ||= Class.new do
      include ActionView::Helpers::NumberHelper
    end.new
  end

end
