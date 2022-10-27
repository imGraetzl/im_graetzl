ActiveAdmin.register SubscriptionPlan do
  menu parent: 'Users'

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :name, :amount, :interval, :stripe_id, :description
end
