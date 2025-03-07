class Subscription < ApplicationRecord
  include Trackable

  belongs_to :user, optional: true
  belongs_to :subscription_plan
  belongs_to :crowd_boost, optional: true
  belongs_to :coupon, optional: true
  has_many :subscription_invoices
  has_many :zuckerls
  string_enum status: ["incomplete", "active", "canceled", "past_due"]

  scope :initialized, -> { where.not(status: :incomplete) }
  scope :on_grace_period, -> { where("ends_at > ?", Time.zone.now) }
  scope :upcoming_invoice, -> { active.where('current_period_end >= ? AND ends_at IS NULL', Date.today) }
  
  after_update :update_user, if: -> { saved_change_to_status? || saved_change_to_current_period_end? }

  # For better Performance use "active?" from status and not def below:
  # def active?
  #  ["active"].include?(status) && ends_at.nil? || on_grace_period?
  # end

  def on_grace_period?
    canceled? && Time.zone.now < ends_at
  end

  def canceled?
    ends_at?
  end

  def past_due?
    ["past_due"].include?(status)
  end

  def region_zuckerl_included?
    subscription_plan.free_region_zuckerl.to_i > 0
  end

  def graetzl_zuckerl_included?
    subscription_plan.free_graetzl_zuckerl.to_i > 0
  end

  def zuckerl_included?
    region_zuckerl_included? || graetzl_zuckerl_included?
  end

  def current_region_zuckerl_period
    current_period_start..current_period_start + (subscription_plan.free_region_zuckerl_monthly_interval.to_i.months)
  end

  def current_region_zuckerl_period_end
    current_period_start + (subscription_plan.free_region_zuckerl_monthly_interval.to_i.months)
  end

  def current_graetzl_zuckerl_period
    current_period_start..current_period_start + (subscription_plan.free_graetzl_zuckerl_monthly_interval.to_i.months)
  end

  def current_graetzl_zuckerl_period_end
    current_period_start + (subscription_plan.free_graetzl_zuckerl_monthly_interval.to_i.months)
  end

  def open_zuckerl?
    active? && (open_zuckerl_count_entire_region > 0 || open_zuckerl_count_graetzl > 0)
  end

  def open_zuckerl_count_entire_region
    count = subscription_plan.free_region_zuckerl.to_i - zuckerls.redeemed.entire_region.where(created_at: current_region_zuckerl_period).count
    count < 0 ? 0 : count
  end

  def open_zuckerl_count_graetzl
    count = subscription_plan.free_graetzl_zuckerl.to_i - zuckerls.redeemed.graetzl.where(created_at: current_graetzl_zuckerl_period).count
    count < 0 ? 0 : count
  end

  def valid_zuckerl_voucher_for(zuckerl)
    if zuckerl.entire_region?
      active? && open_zuckerl_count_entire_region > 0
    else
      active? && open_zuckerl_count_graetzl > 0
    end
  end

  def cancel
    sub = Stripe::Subscription.update(stripe_id, { cancel_at_period_end: true })
    update(status: 'canceled', ends_at: Time.at(sub.cancel_at))
    self.destroy_activity_and_notifications
  end

  def cancel_now!
    sub = Stripe::Subscription.cancel(stripe_id)
    update(status: 'canceled', ends_at: Time.at(sub.ended_at))
    self.destroy_activity_and_notifications
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

  def update_user
    if user && active?
      user.update_attribute(:subscribed, true)
      MailchimpUserTagJob.perform_later(user, 'Abo', 'active')
    elsif user && !incomplete?
      user.update_attribute(:subscribed, false)
      MailchimpUserTagJob.perform_later(user, 'Abo', 'inactive')
    end
  end

end
