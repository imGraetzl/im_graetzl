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

end
