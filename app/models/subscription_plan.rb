class SubscriptionPlan < ApplicationRecord

  belongs_to :crowd_boost, optional: true

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

  private

  def helper
    @helper ||= Class.new do
      include ActionView::Helpers::NumberHelper
    end.new
  end

end
