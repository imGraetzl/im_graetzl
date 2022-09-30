class Subscription < ApplicationRecord
  include Trackable

  belongs_to :user
  belongs_to :subscription_plan

  string_enum status: ["incomplete", "active", "canceled", "past_due"]

  def active?
    ["active"].include?(status) && ends_at.nil? || on_grace_period?
  end

  def on_grace_period?
    canceled? && Time.zone.now < ends_at
  end

  def canceled?
    ends_at?
  end

  def past_due?
    ["past_due"].include?(status)
  end

  def has_incomplete_payment?
    ["past_due", "incomplete"].include?(status)
  end

  def cancel
    sub = Stripe::Subscription.update(stripe_id, { cancel_at_period_end: true })
    update(status: 'canceled', ends_at: Time.at(sub.cancel_at))
  end

  def cancel_now!
    sub = Stripe::Subscription.delete(stripe_id)
    update(status: 'canceled', ends_at: Time.at(sub.ended_at))
  end

  def resume
    if Time.current < ends_at
      Stripe::Subscription.update(stripe_id, cancel_at_period_end: false)
      update(status: 'active', ends_at: nil)
    else
      raise StandardError, "You cannot resume a subscription that has already been canceled."
    end
  end

  def swap(plan)

    args = {
      cancel_at_period_end: false,
      items: [
        {
          id: stripe_subscription.items.data[0].id,
          plan: plan.stripe_id,
        }
      ]
    }

    subscription = Stripe::Subscription.update(stripe_id, args)
    update(
      subscription_plan_id: plan.id,
      stripe_plan: plan.stripe_id,
      ends_at: nil
    )
  end

  def stripe_subscription
    Stripe::Subscription.retrieve(stripe_id)
  end
end
