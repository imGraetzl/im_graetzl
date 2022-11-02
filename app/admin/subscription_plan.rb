ActiveAdmin.register SubscriptionPlan do
  menu parent: 'Users'

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :name, :amount, :interval, :stripe_id, :description,
  :benefit_1, :benefit_2, :benefit_3, :benefit_4, :benefit_5
end
