class SubscriptionPlan < ApplicationRecord

  scope :sorted, ->{ order(amount: :asc) }
  default_scope ->{ sorted }

  def to_s
    name
  end

  def amount_readable
    "#{helper.number_to_currency(amount, unit: "€")} / #{I18n.t("activerecord.attributes.subscription_plan.intervals.#{interval}")}"
  end

  private

  def helper
    @helper ||= Class.new do
      include ActionView::Helpers::NumberHelper
    end.new
  end

end
