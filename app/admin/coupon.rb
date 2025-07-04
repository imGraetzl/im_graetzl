ActiveAdmin.register Coupon do
  menu parent: 'Einstellungen'

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  scope :all, default: true
  scope :once
  scope :forever
  scope :repeating
  scope :currently_valid

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :name
  filter :code
  filter :created_at
  filter :valid_from
  filter :valid_until
  filter :enabled, input_html: { class: 'admin-filter-select'}
  filter :amount_off
  filter :percent_off
  filter :stripe_id

  permit_params :code, :stripe_id, :amount_off, :percent_off, :duration, :valid_from, :valid_until, :subscription_plan_id, :name, :description, :enabled, :region_id

  controller do
    def scoped_collection
      super.includes(coupon_histories: :user).select(<<~SQL.squish)
        coupons.*,
        (
          SELECT COUNT(*) FROM coupon_histories
          WHERE coupon_histories.coupon_id = coupons.id
          AND coupon_histories.sent_at IS NOT NULL
        ) AS sent_count,
        (
          SELECT COUNT(*) FROM coupon_histories
          WHERE coupon_histories.coupon_id = coupons.id
          AND coupon_histories.redeemed_at IS NOT NULL
        ) AS redeemed_count
      SQL
    end
  end

end
