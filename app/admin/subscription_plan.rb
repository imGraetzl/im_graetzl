ActiveAdmin.register SubscriptionPlan do
  menu parent: 'Subscriptions'

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :name, :amount, :interval, :stripe_id, :short_name,
  :benefit_1, :benefit_2, :benefit_3, :benefit_4, :benefit_5,
  :free_region_zuckerl, :free_graetzl_zuckerl,
  :free_region_zuckerl_monthly_interval, :free_graetzl_zuckerl_monthly_interval,
  :image_url, :coupon, :region_id
end
