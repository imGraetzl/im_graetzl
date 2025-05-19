ActiveAdmin.register Coupon do
  menu parent: 'Einstellungen'

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  scope :all, default: true
  scope :once
  scope :forever
  scope :currently_valid

  permit_params :code, :stripe_id, :amount_off, :percent_off, :duration, :valid_from, :valid_until, :subscription_plan_id, :name, :description, :enabled, :region_id

  controller do
    
    before_action :load_coupon_history_counts, only: :index

    private

    def load_coupon_history_counts
      ids = scoped_collection.page(params[:page]).pluck(:id)

      @sent_counts = CouponHistory
        .where(coupon_id: ids)
        .where.not(sent_at: nil)
        .group(:coupon_id)
        .count

      @redeemed_counts = CouponHistory
        .where(coupon_id: ids)
        .where.not(redeemed_at: nil)
        .group(:coupon_id)
        .count
    end
  end
end
